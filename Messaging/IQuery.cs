using RestSpcService.Application.Abstractions.Messaging.Contracts;
using RestSpcService.Domain.SharedKernel.Primitives;
using RestSpcService.Domain.SharedKernel.Primitives.Extensions;

namespace RestSpcService.Application.Abstractions.Messaging;

public interface IQuery : IRequest<Result>
{
}

public interface IQuery<TResponse> : IRequest<Result<TResponse>>
{
}
