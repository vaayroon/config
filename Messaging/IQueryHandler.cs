using RestSpcService.Application.Abstractions.Messaging.Contracts;
using RestSpcService.Domain.SharedKernel.Primitives;
using RestSpcService.Domain.SharedKernel.Primitives.Extensions;

namespace RestSpcService.Application.Abstractions.Messaging;

public interface IQueryHandler<TQuery>
    : IRequestHandler<TQuery, Result>
        where TQuery : IQuery
{
}

public interface IQueryHandler<TQuery, TResponse>
    : IRequestHandler<TQuery, Result<TResponse>>
        where TQuery : IQuery<TResponse>
{
}
