using RestSpcService.Application.Abstractions.Logging;
using RestSpcService.Application.Abstractions.Messaging.Contracts.Pipelines;
using RestSpcService.Application.Core.Exceptions;

namespace RestSpcService.Application.Abstractions.Behaviors;

internal sealed class ExceptionHandlingPipelineBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : class
{
    private readonly IAppLogger<ExceptionHandlingPipelineBehavior<TRequest, TResponse>> _logger;

    public ExceptionHandlingPipelineBehavior(
        IAppLogger<ExceptionHandlingPipelineBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        try
        {
            return await next(cancellationToken);
        }
        catch (Exception exception)
        {
            _logger.LogError(
                exception,
                "Unhandled exception for {@RequestName}, {@DateTimeUtc}",
                request.GetType().Name,
                DateTime.UtcNow);

            throw new MediatorRequestHandlingException(
                request.GetType().Name,
                DateTime.UtcNow,
                exception);
        }
    }
}
