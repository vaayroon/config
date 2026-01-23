using RestSpcService.Application.Abstractions.Logging;
using RestSpcService.Application.Abstractions.Messaging.Contracts;
using RestSpcService.Application.Abstractions.Messaging.Contracts.Pipelines;
using RestSpcService.Domain.SharedKernel.Primitives;

namespace RestSpcService.Application.Abstractions.Behaviors;

internal sealed class RequestLoggingPipelineBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
    where TResponse : Result
{
    private readonly IAppLogger<RequestLoggingPipelineBehavior<TRequest, TResponse>> _logger;

    public RequestLoggingPipelineBehavior(
        IAppLogger<RequestLoggingPipelineBehavior<TRequest, TResponse>> logger)
    {
        _logger = logger;
    }

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        string requestName = request.GetType().Name;
        _logger.LogInformation(
            "Starting request: {@RequestType}, {@DateTimeUtc}",
            requestName,
            DateTime.UtcNow);

        TResponse result = await next(cancellationToken);

        if (result.IsFailure)
        {
            _logger.LogError(
                "Failure request: {@RequestType}, {@Error}, {@DateTimeUtc}",
                requestName,
                result.Error,
                DateTime.UtcNow);
        }
        else
        {
            _logger.LogInformation(
                "Completed request: {@RequestType}, {@DateTimeUtc}",
                requestName,
                DateTime.UtcNow);
        }

        return result;
    }
}
