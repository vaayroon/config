using FluentValidation;
using FluentValidation.Results;
using RestSpcService.Application.Abstractions.Logging;
using RestSpcService.Application.Abstractions.Messaging.Contracts;
using RestSpcService.Application.Abstractions.Messaging.Contracts.Pipelines;
using RestSpcService.Domain.SharedKernel.Primitives;
using RestSpcService.Domain.SharedKernel.Primitives.Extensions;
using RestSpcService.Domain.SharedKernel.Validation;

namespace RestSpcService.Application.Abstractions.Behaviors;

internal sealed class FluentValidationPipelineBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
        where TRequest : IRequest<TResponse>
        where TResponse : Result
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;
    private readonly IAppLogger<FluentValidationPipelineBehavior<TRequest, TResponse>> _logger;

    public FluentValidationPipelineBehavior(
        IEnumerable<IValidator<TRequest>> validators,
        IAppLogger<FluentValidationPipelineBehavior<TRequest, TResponse>> logger)
    {
        _validators = validators;
        _logger = logger;
    }

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        if (!_validators.Any())
        {
            _logger.LogInformation(
                "Skipping fluent validation request: {@RequestType}, {@DateTimeUtc}",
                request.GetType().Name,
                DateTime.UtcNow);
            return await next(cancellationToken);
        }

        string requestName = request.GetType().Name;
        ValidationFailure[] validationFailures = await ValidateAsync(request);

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

        throw new ValidationException(validationFailures);
    }

    private static Error[] CreateValidationError(ValidationFailure[] validationFailures)
    {
        return [.. validationFailures.Select(f => Error.Problem(f.PropertyName, f.ErrorMessage))];
    }

    private async Task<ValidationFailure[]> ValidateAsync(TRequest request)
    {
        _logger.LogInformation(
            "Starting validation request: {@RequestType}, {@DateTimeUtc}",
            request.GetType().Name,
            DateTime.UtcNow);

        var context = new ValidationContext<TRequest>(request);

        ValidationResult[] validationResults = await Task.WhenAll(
            _validators.Select(validator => validator.ValidateAsync(context)));

        ValidationFailure[] validationFailures = [.. validationResults
            .Where(validationResult => !validationResult.IsValid)
            .SelectMany(validationResult => validationResult.Errors)];

        return validationFailures;
    }
}
