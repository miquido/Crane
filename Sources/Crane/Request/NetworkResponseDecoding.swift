import class Foundation.JSONDecoder
import struct Foundation.Data

public struct NetworkResponseDecoding<Variable, Response> {
  
  public var decode: (HTTPResponse, Variable) -> Result<Response, NetworkError>
  
  public init(decode: @escaping (HTTPResponse, Variable) -> Result<Response, NetworkError>) {
    self.decode = decode
  }
}

public extension NetworkResponseDecoding {
  
  func callAsFunction(
    from response: HTTPResponse,
    with variable: Variable
  ) -> Result<Response, NetworkError> {
    decode(response, variable)
  }
  
  func withFallback(_ decoding: NetworkResponseDecoding) -> Self {
    Self { response, variable in
      self.decode(response, variable)
        .flatMapError { _ in
          decoding.decode(response, variable)
        }
    }
  }
}

public extension NetworkResponseDecoding where Response == Void {
  
  static var empty: Self {
    Self { response, _ in
      guard case 200..<300 = response.statusCode
      else { return .failure(.responseDecodingFailure(extensions: [.httpResponse: response])) }
      return .success(())
    }
  }
}

public extension NetworkResponseDecoding where Response == HTTPResponse {
  
  static var http: Self {
    Self { response, _ in
      .success(response)
    }
  }
}

public extension NetworkResponseDecoding where Response == Data {
  
  static var rawBody: Self {
    Self { response, _ in
      .success(response.body.rawValue)
    }
  }
}

public extension NetworkResponseDecoding where Response == String {
  
  static func bodyAsString(
    withEncoding encoding: String.Encoding = .utf8
  ) -> Self {
    Self { response, _ in
      guard let string = String(data: response.body.rawValue, encoding: encoding)
      else { return .failure(.responseDecodingFailure(extensions: [.httpResponse: response])) }
      return .success(string)
    }
  }
}


public extension NetworkResponseDecoding where Response: Decodable {
  
  static func json(using decoder: JSONDecoder = JSONDecoder()) -> Self {
    Self { response, _ in
      do {
        return .success(try decoder.decode(Response.self, from: response.body.rawValue))
      } catch {
        return .failure(.responseDecodingFailure(reason: error, extensions: [.httpResponse: response]))
      }
    }
  }
}
