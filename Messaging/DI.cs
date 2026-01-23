using System.Reflection;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using RestSpcService.Application.Abstractions.Behaviors;
using RestSpcService.Application.Abstractions.Messaging.Contracts;
using RestSpcService.Application.Abstractions.Messaging.Contracts.Pipelines;
using RestSpcService.Application.Abstractions.Messaging.Contracts.Services;
using RestSpcService.Application.Infrastructure.Configuration;

namespace RestSpcService.Application;

/// <summary>
/// Provides extension methods for adding application services.
/// </summary>
public static class DependencyInjection
{
    /// <summary>
    /// Adds application services.
    /// </summary>
    /// <param name="services"> The <see cref="IServiceCollection"/> to add services to. </param>
    /// <returns> The <see cref="IServiceCollection"/> so that additional calls can be chained. </returns>
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.SetUpOptionsSettings();
        services.SetupMediatorWithPipeline();
        services.SetupFluentValidators();
        return services;
    }

    /// <summary>
    /// Adds command and query handlers.
    /// </summary>
    /// <param name="services"> The <see cref="IServiceCollection"/> to add services to. </param>
    /// <param name="assembly"> The <see cref="Assembly"/> to scan for handlers. </param>
    private static void RegisterMediatorHandlers(this IServiceCollection services, Assembly assembly)
    {
        var handlerTypes = assembly.GetTypes()
            .Where(t => !t.IsAbstract && !t.IsInterface)
            .SelectMany(t => t.GetInterfaces(), (t, i) => new { Type = t, Interface = i })
            .Where(static t => t.Interface.IsGenericType
                && (t.Interface.GetGenericTypeDefinition() == typeof(IRequestHandler<,>) || t.Interface.GetGenericTypeDefinition() == typeof(IRequestHandler<>)))
            .ToList();

        foreach (var handler in handlerTypes)
        {
            services.AddTransient(handler.Interface, handler.Type);
        }
    }

    /// <summary>
    /// Adds pipeline behaviors.
    /// </summary>
    /// <param name="services"> The <see cref="IServiceCollection"/> to add services to. </param>
    private static void RegisterMediatorPipelines(this IServiceCollection services)
    {
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ExceptionHandlingPipelineBehavior<,>));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(RequestLoggingPipelineBehavior<,>));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(DataAnnotationsValidationBehavior<,>));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(FluentValidationPipelineBehavior<,>));
    }

    /// <summary>
    /// Sets up the mediator with pipeline behaviors.
    /// </summary>
    /// <param name="services"> The <see cref="IServiceCollection"/> to add services to. </param>
    /// <remarks>
    /// This method registers the <see cref="IMediator"/> implementation and the pipeline behaviors.
    /// It also registers the command and query handlers found in the current assembly.
    /// </remarks>
    private static void SetupMediatorWithPipeline(this IServiceCollection services)
    {
        services.AddTransient<IMediator, Mediator>();
        services.RegisterMediatorHandlers(Assembly.GetExecutingAssembly());
        services.RegisterMediatorPipelines();
    }

    /// <summary>
    /// Sets up Application options settings.
    /// </summary>
    /// <param name="services"> The <see cref="IServiceCollection"/> to add services to. </param>
    private static void SetUpOptionsSettings(this IServiceCollection services)
    {
        services.AddOptions<ApplicationOptions>()
            .BindConfiguration("Application")
            .ValidateDataAnnotations()
            .ValidateOnStart();
    }

    private static IServiceCollection SetupFluentValidators(this IServiceCollection services)
    {
        ValidatorOptions.Global.DefaultRuleLevelCascadeMode = CascadeMode.Stop;
        services.AddValidatorsFromAssembly(
            typeof(DependencyInjection).Assembly,
            includeInternalTypes: true);
        return services;
    }
}
