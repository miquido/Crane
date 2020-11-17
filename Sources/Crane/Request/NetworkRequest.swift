/// Type describing network requests and its expected results.
public struct NetworkRequest<Variable, Response, Fault: NetworkError> {
  
  public var execute: (
    Variable,
    CancelationToken,
    @escaping (Result<Response, Fault>) -> Void
  ) -> CancelationToken
  
  @usableFromInline internal init(
    _ execute: @escaping (
      Variable,
      CancelationToken,
      @escaping (Result<Response, Fault>) -> Void
    ) -> CancelationToken) {
    self.execute = execute
  }
}

public extension NetworkRequest {
  
  typealias Template = NetworkRequestTemplate<Variable>
  typealias Encoding = NetworkRequestEncoding<Variable, Fault>
  typealias Decoding = NetworkResponseDecoding<Variable, Response, Fault>
}

public extension NetworkRequest {
  
  @discardableResult @inlinable func callAsFunction(
    _ variable: Variable,
    cancelation: CancelationToken = .manual,
    completion: @escaping (Result<Response, Fault>) -> Void
  ) -> CancelationToken {
    execute(variable, cancelation, completion)
  }
}

public extension NetworkRequest where Variable == Void {
  
  @discardableResult @inlinable func callAsFunction(
    cancelation: CancelationToken = .manual,
    completion: @escaping (Result<Response, Fault>) -> Void
  ) -> CancelationToken {
    execute(Void(), cancelation, completion)
  }
}

public extension NetworkRequest {
  
  @inlinable static func http<SessionVariables>(
    using session: NetworkSession<SessionVariables>,
    request encoding: Encoding,
    response decoding: Decoding
  ) -> Self {
    Self { variable, cancelation, completion in
      guard !cancelation.isCanceled
      else {
        completion(.failure(.canceled))
        return cancelation
      }
      switch encoding(variable) {
      case let .success(httpRequest):
        return session.requestExecutor(execute: httpRequest, cancelation: cancelation) { result in
          switch result {
          case let .success(httpResponse):
            completion(decoding(from: httpResponse, with: variable))
          case let .failure(error):
            completion(.failure(.httpError(error)))
          }
        }
      case let .failure(error):
        completion(.failure(error))
        return cancelation
      }
    }
  }
  
  @inlinable static func http<SessionVariables>(
    using session: NetworkSession<SessionVariables>,
    request template: Template,
    response decoding: Decoding
  ) -> Self {
    return .http(
      using: session,
      request: .template(template),
      response: decoding
    )
  }
  
  @inlinable static func http<SessionVariables>(
    using session: NetworkSession<SessionVariables>,
    request templateModifiers: HTTPRequestModifier<Variable>...,
    response decoding: Decoding
  ) -> Self {
    return .http(
      using: session,
      request: NetworkRequestTemplate(templateModifiers),
      response: decoding
    )
  }
}
