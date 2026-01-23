using System.Collections.Concurrent;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using RestSpcService.Application.Abstractions.Logging;
using RestSpcService.Application.Abstractions.Messaging.Contracts;
using RestSpcService.Application.Abstractions.Messaging.Contracts.Pipelines;
using RestSpcService.Application.Core.Exceptions;
using RestSpcService.Domain.SharedKernel.Primitives;
using RestSpcService.Domain.SharedKernel.Primitives.Extensions;
using RestSpcService.Domain.SharedKernel.Validation;

namespace RestSpcService.Application.Abstractions.Behaviors;

internal sealed class DataAnnotationsValidationBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
        where TRequest : IRequest<TResponse>
{
    private static readonly ConcurrentDictionary<Type, bool> _typeHasValidationCache = new();

    private readonly IAppLogger<DataAnnotationsValidationBehavior<TRequest, TResponse>> _logger;

    public DataAnnotationsValidationBehavior(IAppLogger<DataAnnotationsValidationBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        Type requestType = request.GetType();
        string requestName = requestType.Name;

        if (!HasValidationAttributes(requestType))
        {
            _logger.LogInformation(
                "Skipping data annotation validation request: {@RequestType}, {@DateTimeUtc}",
                requestName,
                DateTime.UtcNow);
            return await next(cancellationToken);
        }

        ValidationResult[] validationFailures = Validate(request);

        if (validationFailures.Length == 0)
        {
            _logger.LogInformation(
                "Completed validation request: {@RequestType}, {@DateTimeUtc}",
                requestName,
                DateTime.UtcNow);
            return await next(cancellationToken);
        }

        _logger.LogError(
            "Failure validation request {@RequestType}, {@ValidationErrors}, {@DateTimeUtc}",
            requestName,
            validationFailures,
            DateTime.UtcNow);

        Error[] validationErrors = CreateValidationError(validationFailures);

        if (typeof(TResponse).IsGenericType &&
            typeof(TResponse).GetGenericTypeDefinition() == typeof(Result<>))
        {
            object customValidationResult = typeof(CustomValidationResult<>)
                .GetGenericTypeDefinition()
                .MakeGenericType(typeof(TResponse).GenericTypeArguments[0])
                .GetMethod(nameof(CustomValidationResult.WithErrors))!
                .Invoke(null, [validationErrors])!;
            return (TResponse)customValidationResult;
        }
        else if (typeof(TResponse) == typeof(Result))
        {
            object customValidationResult = CustomValidationResult.WithErrors(validationErrors);
            return (TResponse)customValidationResult;
        }

        throw new DataAnnotationsValidationException(validationFailures);
    }

    private static bool HasValidationAttributes(Type type)
    {
        return _typeHasValidationCache.GetOrAdd(type, t =>
        {
            PropertyInfo[] properties = t.GetProperties();

            foreach (PropertyInfo property in properties)
            {
                if (property.GetCustomAttributes(typeof(ValidationAttribute), true).Length != 0)
                {
                    return true;
                }

                Type propertyType = property.PropertyType;
                if (!propertyType.IsPrimitive &&
                    propertyType != typeof(string) &&
                    propertyType != typeof(DateTime) &&
                    !propertyType.IsEnum &&
                    !propertyType.IsArray &&
                    !propertyType.IsGenericType &&
                    HasValidationAttributes(propertyType))
                {
                    return true;
                }
            }

            if (t.GetCustomAttributes(typeof(ValidationAttribute), true).Length != 0)
            {
                return true;
            }

            return false;
        });
    }

    private static Error[] CreateValidationError(ValidationResult[] validationFailures)
    {
        return [.. validationFailures.Select(vf => Error.Problem(vf.MemberNames.FirstOrDefault() ?? string.Empty, vf.ErrorMessage ?? "Validation failed"))];
    }

    private ValidationResult[] Validate(TRequest request)
    {
        _logger.LogInformation(
            "Starting validation request: {@RequestType}, {@DateTimeUtc}",
            request.GetType().Name,
            DateTime.UtcNow);

        var context = new ValidationContext(request);
        var validationResults = new List<ValidationResult>();
        bool isValid = Validator.TryValidateObject(
            request,
            context,
            validationResults,
            validateAllProperties: true);

        if (isValid)
        {
            return [];
        }
        else
        {
            return [.. validationResults];
        }
    }
}
