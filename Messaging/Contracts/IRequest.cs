using System.Diagnostics.CodeAnalysis;

namespace RestSpcService.Application.Abstractions.Messaging.Contracts;

public interface IRequest : IBaseRequest
{
}

[SuppressMessage("SonarQube", "S2326:Unused type parameters should be removed", Justification = "This is a generic interface for requests.")]
public interface IRequest<out TResponse> : IBaseRequest
{
}
