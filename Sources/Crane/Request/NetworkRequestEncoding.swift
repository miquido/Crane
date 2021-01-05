import struct Foundation.URL

public struct NetworkRequestEncoding<Variable, Failure: NetworkError> {
  
  public var encode: (Variable) -> Result<HTTPRequest, Failure>
  
  public init(_ encode: @escaping (Variable) -> Result<HTTPRequest, Failure>) {
    self.encode = encode
  }
}

public extension NetworkRequestEncoding {
  
  func callAsFunction(
    _ variable: Variable
  ) -> Result<HTTPRequest, Failure> {
    encode(variable)
  }
}

public extension NetworkRequestEncoding where Variable: Encodable {
  
  static func json(
    url: URL,
    method: HTTPMethod = .post,
    headers: HTTPHeaders = [:]
  ) -> Self {
    Self { variables in
      Result {
        HTTPRequest(
          url: url,
          method: method,
          headers: headers,
          body: try .json(from: variables)
        )
      }
      .mapError(Failure.encodingFailed)
    }
  }
}

public extension NetworkRequestEncoding {
  
  static func template(_ modifiers: HTTPRequestModifier<Variable>...) -> Self {
    template(NetworkRequestTemplate(modifiers))
  }
  
  static func template(_ template: NetworkRequestTemplate<Variable>) -> Self {
    Self { variable in
      template.request(with: variable).mapError(Failure.encodingFailed)
    }
  }
}
