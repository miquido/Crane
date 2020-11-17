import struct Foundation.Data
import struct Foundation.URL
import struct Foundation.URLComponents

/// HTTPRequest abstraction. It does not modify nor generates its fields except adding percent encoding to URL query and path.
public struct HTTPRequest {
  /// HTTP method of this request.
  public var method: HTTPMethod
  /// Headers of this request. Please note that it might not be all of headers used by network client.
  /// i.e. 'content-length' or 'host' headers might be added when executing a request since those are required by HTTP
  /// and might be generated based on other parts of request.
  public var headers: HTTPHeaders
  /// Body of this request.
  public var body: HTTPBody
  private var urlComponents: URLComponents
  /// Initialize request with all fields. Please note that request without valid URL is not a valid request.
  /// - parameter url: URL of this request.
  /// - parameter method: HTTP method of this request. Default is GET.
  /// - parameter headers: Headers of this request. Default is empty.
  /// - parameter body: Body of this request. Default is empty.
  /// - parameter timeout: Timeout time for request execution. Default is 30 sec.
  public init(
    url: URL,
    method: HTTPMethod = .get,
    headers: HTTPHeaders = .empty,
    body: HTTPBody = .empty
  ) {
    self.init(
      url: .some(url),
      method: method,
      headers: headers,
      body: body
    )
  }
  
  internal init(
    url: URL? = .none,
    method: HTTPMethod = .get,
    headers: HTTPHeaders = .empty,
    body: HTTPBody = .empty
  ) {
    self.method = method
    self.urlComponents = url
      .flatMap {
        URLComponents(url: $0, resolvingAgainstBaseURL: true)
      }
      ?? URLComponents()
    self.headers = headers
    self.body = body
  }
}

public extension HTTPRequest {
  /// URL of this request. Might be nil if not provided or its components does not form a valid URL.
  /// You can modify each of its components individually.
  /// - note: Request without valid URL is not a valid request.
  /// - warning: Setting request URL will replace all other URL components such as port, path, query etc.
  var url: URL? {
    get { urlComponents.url }
    set {
      urlComponents = newValue
        .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: true) }
        ?? urlComponents
    }
  }
  /// Scheme component of this request's URL.
  var scheme: String? {
    get { urlComponents.scheme }
    set { urlComponents.scheme = newValue }
  }
  /// Host component of this request's URL.
  var host: String? {
    get { urlComponents.host }
    set { urlComponents.host = newValue }
  }
  /// Port component of this request's URL.
  var port: Int? {
    get { urlComponents.port }
    set { urlComponents.port = newValue }
  }
  /// Path component of this request's URL.
  var path: URLPath {
    get { URLPath(urlComponents.path) }
    set { urlComponents.percentEncodedPath = newValue.percentEncodedString }
  }
  /// Query component of this request's URL.
  var urlQuery: URLQuery {
    get { URLQuery(urlComponents.queryItems ?? []) }
    set { urlComponents.percentEncodedQuery = newValue.percentEncodedString }
  }
}
