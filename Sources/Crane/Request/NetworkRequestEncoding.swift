import struct Foundation.URL

public struct NetworkRequestEncoding<Variable> {
  
  public var encode: (Variable) -> Result<HTTPRequest, NetworkError>
  
  public init(_ encode: @escaping (Variable) -> Result<HTTPRequest, NetworkError>) {
    self.encode = encode
  }
}

public extension NetworkRequestEncoding {
  
  func callAsFunction(
    _ variable: Variable
  ) -> Result<HTTPRequest, NetworkError> {
    encode(variable)
  }
}

public extension NetworkRequestEncoding where Variable: Encodable {
  
  static func json(
    url: URL,
    method: HTTPMethod = .post,
    headers: HTTPHeaders = [:]
  ) -> Self {
    Self { variable in
      Result {
        HTTPRequest(
          url: url,
          method: method,
          headers: headers,
          body: try .json(from: variable)
        )
      }
      .mapError { error in
        if let networkError = error as? NetworkError {
          return networkError
        } else {
          return .requestEncodingFailure(reason: error, extensions: [.requestVariables: variable])
        }
      }
    }
  }
}

public extension NetworkRequestEncoding {
  
  static func template(_ modifiers: HTTPRequestModifier<Variable>...) -> Self {
    template(NetworkRequestTemplate(modifiers))
  }
  // to decide which version is better, there is probably no need for both array and varargs
  static func template(_ modifiers: Array<HTTPRequestModifier<Variable>>) -> Self {
    template(NetworkRequestTemplate(modifiers))
  }
  
  static func template(_ template: NetworkRequestTemplate<Variable>) -> Self {
    Self { variable in
      template
        .request(with: variable)
        .mapError { error in
          if let networkError = error as? NetworkError {
            return networkError
          } else {
            return .requestEncodingFailure(reason: error, extensions: [.requestVariables: variable])
          }
        }
    }
  }
}
