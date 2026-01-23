using RestSpcService.Application.Abstractions.Messaging.Contracts;
using RestSpcService.Domain.SharedKernel.Primitives;
using RestSpcService.Domain.SharedKernel.Primitives.Extensions;

namespace RestSpcService.Application.Abstractions.Messaging;

public interface ICommandHandler<TCommand>
    : IRequestHandler<TCommand, Result>
        where TCommand : ICommand
{
}

public interface ICommandHandler<TCommand, TResponse>
    : IRequestHandler<TCommand, Result<TResponse>>
        where TCommand : ICommand<TResponse>
{
}
