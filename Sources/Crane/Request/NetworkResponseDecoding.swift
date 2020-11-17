import class Foundation.JSONDecoder
import struct Foundation.Data

public struct NetworkResponseDecoding<Variable, Response, Failure: NetworkError> {
  
  public var decode: (HTTPResponse, Variable) -> Result<Response, Failure>
}

public extension NetworkResponseDecoding {
  
  func callAsFunction(
    from response: HTTPResponse,
    with variable: Variable
  ) -> Result<Response, Failure> {
    decode(response, variable)
  }
}

public extension NetworkResponseDecoding where Response == Void {
  
  static var empty: Self {
    Self { response, _ in
      guard case 200..<300 = response.statusCode
      else { return .failure(.decodingFailed(nil)) }
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
      else { return .failure(.decodingFailed(nil)) }
      return .success(string)
    }
  }
}


public extension NetworkResponseDecoding where Response: Decodable {
  
  static var json: Self {
    Self { response, _ in
      guard case 200..<300 = response.statusCode
      else { return .failure(.decodingFailed(nil)) }
      do {
        return .success(try jsonDecoder.decode(Response.self, from: response.body.rawValue))
      } catch {
        return .failure(.decodingFailed(error))
      }
    }
  }
}

private let jsonDecoder = JSONDecoder()
