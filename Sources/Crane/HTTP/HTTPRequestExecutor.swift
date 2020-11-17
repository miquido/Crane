import class Foundation.NSURLSession.URLSession
import class Foundation.NSURLSession.URLSessionConfiguration
import struct Foundation.URLRequest
import class Foundation.NSError
import struct Foundation.TimeInterval
import let Foundation.NSURLErrorCancelled
import let Foundation.NSURLErrorNotConnectedToInternet
import let Foundation.NSURLErrorTimedOut

/// Executor of HTTP requests.
public struct HTTPRequestExecutor {
  
  public var execute: (
    HTTPRequest,
    CancelationToken,
    @escaping (Result<HTTPResponse, HTTPError>) -> Void
  ) -> CancelationToken
}

public extension HTTPRequestExecutor {
  
  @discardableResult func callAsFunction(
    execute request: HTTPRequest,
    cancelation: CancelationToken = .manual,
    completion: @escaping (Result<HTTPResponse, HTTPError>) -> Void
  ) -> CancelationToken {
    execute(request, cancelation, completion)
  }
}

//import Foundation
// TODO: prepare custom executor based on Network framework
public extension HTTPRequestExecutor {
  /// HTTPRequestExecutor implementation using Foundation URLRequest and URLSession.
  static func urlSession(
    _ configuration: URLSessionConfiguration = .ephemeral,
    httpShouldHandleCookies: Bool = false
  ) -> Self {
    let session = URLSession(configuration: configuration)
    return Self { request, cancelation, completion in
      guard !cancelation.isCanceled
      else {
        completion(.failure(.canceled))
        return cancelation
      }
      guard let url = request.url
      else {
        completion(.failure(.invalidRequest))
        return cancelation
      }
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = request.method.rawValue
      urlRequest.httpBody = request.body.rawValue
      urlRequest.allHTTPHeaderFields = request.headers.rawDictionary
      urlRequest.timeoutInterval = configuration.timeoutIntervalForRequest
      urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
      urlRequest.httpShouldHandleCookies = httpShouldHandleCookies
      let task = session.dataTask(with: urlRequest) { data, response, error in
        guard !cancelation.isCanceled
        else { return completion(.failure(.canceled)) }
        if let error: NSError = error as NSError? {
          switch error.code {
          case NSURLErrorCancelled:
            completion(.failure(.canceled))
          case NSURLErrorNotConnectedToInternet:
            completion(.failure(.cannotConnect))
          case NSURLErrorTimedOut:
            completion(.failure(.timeout))
          case _: // TODO: fill with more known errors
            completion(.failure(.other(error)))
          }
        } else if let response = response.flatMap({ HTTPResponse(from: $0, body: data) }) {
          completion(.success(response))
        } else {
          completion(.failure(.invalidResponse))
        }
      }
      task.resume()
      return .combined(cancelation, .withClosure(task.cancel))
    }
  }
}

public extension HTTPRequestExecutor {
  
  func withRequestModifier<Variable>(
    _ modifier: HTTPRequestModifier<Variable>,
    using variable: Variable
  ) -> Self {
    Self { request, cancelation, completion in
      switch modifier(appliedOn: request, using: variable) {
      case let .success(request):
        return self(execute: request, cancelation: cancelation, completion: completion)
      case let .failure(error):
        completion(.failure(.other(error)))
        return .canceled
      }
    }
  }
  
  func withRequestModifier(_ modifier: HTTPRequestModifier<Void>) -> Self {
    Self { request, cancelation, completion in
      switch modifier(appliedOn: request, using: Void()) {
      case let .success(request):
        return self(execute: request, cancelation: cancelation, completion: completion)
      case let .failure(error):
        completion(.failure(.other(error)))
        return .canceled
      }
    }
  }
}
