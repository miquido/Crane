#if canImport(Combine)
import Combine

@available(iOS 13.0, OSX 10.15, *)
extension NetworkRequest {
  
  internal final class Subscription<Target: Subscriber>: Combine.Subscription
  where Target.Failure == Never, Target.Input == Result<Response, Fault> {
    
    private let request: NetworkRequest
    private let variable: Variable
    private var cancelation: CancelationToken
    private var target: Target

    internal init(
      request: NetworkRequest,
      variable: Variable,
      cancelation: CancelationToken,
      target: Target
    ) {
      self.request = request
      self.variable = variable
      self.cancelation = cancelation
      self.target = target
    }
    
    internal func request(_ demand: Subscribers.Demand) {
      guard !cancelation.isCanceled
      else {
        _ = self.target.receive(.failure(.canceled))
        return self.target.receive(completion: .finished)
      }
      request(variable, cancelation: cancelation) { [weak self] result in
        guard let self = self
        else { return }
        guard !self.cancelation.isCanceled
        else {
          _ = self.target.receive(.failure(.canceled))
          return self.target.receive(completion: .finished)
        }
        switch result {
        case let .success(response):
          _ = self.target.receive(.success(response))
          self.target.receive(completion: .finished)
        case let .failure(error):
          _ = self.target.receive(.failure(error))
          self.target.receive(completion: .finished)
        }
      }
    }
    
    internal func cancel() {
      cancelation.cancel()
      // TODO: verify if that is required
//      _ = self.target.receive(.failure(.canceled))
//      self.target.receive(completion: .finished)
    }
  }
  
  public struct Publisher: Combine.Publisher {
    
    public typealias Output = Result<Response, Fault>
    public typealias Failure = Never

    internal let request: NetworkRequest
    internal let variable: Variable
    internal var cancelation: CancelationToken
    
    public func receive<S>(subscriber: S)
    where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
      subscriber.receive(
        subscription: Subscription<S>(
          request: request,
          variable: variable,
          cancelation: cancelation,
          target: subscriber
        )
      )
    }
  }

  public func publisher(
    with variable: Variable,
    cancelation: CancelationToken = .manual
  ) -> Publisher {
    Publisher(request: self, variable: variable, cancelation: cancelation)
  }
}

#endif
