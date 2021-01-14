import struct Foundation.URL
import struct Foundation.TimeInterval

#warning("TODO: fill docs")
public struct HTTPRequestModifier<Variable> {

  private let modifier: (
    HTTPRequest,
    Variable
  ) throws -> HTTPRequest
  
  internal init(
    _ modifier: @escaping (
      HTTPRequest,
      Variable
    ) throws -> HTTPRequest
  ) {
    self.modifier = modifier
  }
}

public extension HTTPRequestModifier {
  
  func callAsFunction(
    appliedOn request: HTTPRequest,
    using variable: Variable
  ) -> Result<HTTPRequest, Error> {
    Result { try modifier(request, variable) }
  }
}

public extension HTTPRequestModifier
where Variable == Void {
  
  func callAsFunction(
    appliedOn request: HTTPRequest
  ) -> Result<HTTPRequest, Error> {
    Result { try modifier(request, Void()) }
  }
}

public extension HTTPRequestModifier {
  
  init(_ modifiers: Self...) {
    self.init({ request, variable in
      var request = request
      for modifier in modifiers {
        request = try modifier.modifier(request, variable)
      }
      return request
    })
  }
  
  static func combined(
    _ modifiers: Self...
  ) -> Self {
    Self({ request, variable in
      var request = request
      for modifier in modifiers {
        request = try modifier.modifier(request, variable)
      }
      return request
    })
  }
  
  static func when(
    _ condition: @autoclosure () -> Bool,
    then: () -> Self,
    else: () -> Self
  ) -> Self {
    switch condition() {
    case true:
      return then()
    case false:
      return `else`()
    }
  }
  
  static func when(
    _ condition: @autoclosure () -> Bool,
    then: () -> Self
  ) -> Self {
    switch condition() {
    case true:
      return then()
    case false:
      return .empty
    }
  }
  
  static func with<T>(
    _ optional: @autoclosure () -> T?,
    then: (T) -> Self,
    else: () -> Self
  ) -> Self {
    switch optional() {
    case let .some(value):
      return then(value)
    case .none:
      return `else`()
    }
  }
  
  static func with<T>(
    _ optional: @autoclosure () -> T?,
    then: (T)  -> Self
  ) -> Self {
    switch optional() {
    case let .some(value):
      return then(value)
    case .none:
      return .empty
    }
  }
}

public extension HTTPRequestModifier {
  /// Empty modifier. Does nothing.
  static var empty: Self { .init() }
  /// Error modifier. Always fail with provided error.
  static func error(_ error: Error) -> Self {
    HTTPRequestModifier { _, _ in throw error }
  }
}

public extension HTTPRequestModifier {
  
  static func withVariable(
    _ modifier: @escaping (Variable) throws -> Self
  ) -> Self {
    HTTPRequestModifier { request, variable in
      try modifier(variable).modifier(request, variable)
    }
  }
  /// Modifier which sets request's URL scheme.
  /// - parameter path: URL scheme to be set.
  /// - parameter override: Determines if previous scheme will be overridden in case of conflict.
  /// On false current scheme will be preserved if it already exists or set otherwise.
  /// On true new scheme will be always set. Default is true.
  static func scheme(
    _ scheme: String,
    override: Bool = true
  ) -> Self {
    Self { request, _ in
      guard request.scheme == nil || override
      else { return request }
      var request = request
      request.scheme = scheme
      return request
    }
  }
  /// Modifier which sets request's URL.
  /// - parameter url: URL to be set.
  /// - warning: Setting request URL will replace all other URL components such as port, path, query etc.
  static func url(_ url: URL) -> Self {
    Self { request, _ in
      var request = request
      request.url = url
      return request
    }
  }
  /// Modifier which sets request's URL.
  /// - parameter url: URL to be set.
  /// - warning: Setting request URL will replace all other URL components such as port, path, query etc.
  static func url(_ urlString: StaticString) -> Self {
    Self { request, _ in
      var request = request
      request.url = URL(string: "\(urlString)")!
      return request
    }
  }
  /// Modifier which sets request's URL host.
  /// - parameter host: URL host to be set.
  static func host(_ host: String) -> Self {
    Self { request, _ in
      var request = request
      request.host = host
      return request
    }
  }
  /// Modifier which sets request's URL port.
  /// - parameter port: URL port to be set.
  /// - parameter override: Determines if previous port will be overridden in case of conflict.
  /// On false current port will be preserved if it already exists or set otherwise.
  /// On true new port will be always set. Default is true.
  static func port(
    _ port: Int,
    override: Bool = true
  ) -> Self {
    Self { request, _ in
      guard request.port == nil || override
      else { return request }
      var request = request
      request.port = port
      return request
    }
  }
  /// Modifier which prepends path at the end of request's URL path.
  /// - parameter path: Path to prepend.
  static func pathPrefix(_ path: URLPath) -> Self {
    Self { request, _ in
      var request = request
      request.path.prepend(path)
      return request
    }
  }
  /// Modifier which sets request's URL path.
  /// - parameter path: URL path to be set.
  /// - parameter override: Determines if previous path will be overridden in case of conflict.
  /// On false current path will be preserved if it already exists or set otherwise.
  /// On true new path will be always set. Default is true.
  static func path(
    _ path: URLPath,
    override: Bool = true
  ) -> Self {
    Self { request, _ in
      guard request.path.isEmpty || override
      else { return request }
      var request = request
      request.path = path
      return request
    }
  }
  /// Modifier which appends path at the end of request's URL path.
  /// - parameter path: Path to append.
  static func pathSuffix(_ path: URLPath) -> Self {
    Self { request, _ in
      var request = request
      request.path.append(path)
      return request
    }
  }
  /// Modifier which sets request's URL query items.
  /// - parameter urlQuery: URL query to be set.
  /// - parameter override: Determines if previous values will be overridden in case of conflict.
  /// On false current values will be preserved if it already exists or set otherwise.
  /// On true new values will be always set. Default is true.
  static func query(
    _ urlQuery: URLQuery,
    override: Bool = true
  ) -> Self {
    Self { request, _ in
      var request = request
      request.urlQuery.merge(with: urlQuery, override: override)
      return request
    }
  }
  /// Modifier which sets request's single URL query item.
  /// - parameter itemName: Name of URL query item to be set.
  /// - parameter value: Value of URL query item to be set.
  /// - parameter override: Determines if previous value will be overridden in case of conflict.
  /// On false current value will be preserved if it already exists or set otherwise.
  /// On true new value will be always set. Default is true.
  static func queryItem<Value>(
    _ itemName: URLQueryItemName,
    value: Value,
    override: Bool = true
  ) -> Self
  where Value: URLQueryItemValue {
    Self { request, _ in
      var request = request
      guard request.urlQuery[itemName] as String? == nil || override
      else { return request }
      request.urlQuery[itemName] = value
      return request
    }
  }
  /// Modifier which sets request's HTTP method.
  /// - parameter method: HTTP method to be set.
  static func method(_ method: HTTPMethod) -> Self {
    Self { request, _ in
      var request = request
      request.method = method
      return request
    }
  }
  /// Modifier which sets request's HTTP headers.
  /// - parameter headers: HTTP headers to be set.
  /// - parameter override: Determines if previous values will be overridden in case of conflict.
  /// On false current values will be preserved if it already exists or set otherwise.
  /// On true new values will be always set. Default is true.
  static func headers(
    _ headers: HTTPHeaders,
    override: Bool = true
  ) -> Self {
    Self { request, _ in
      var request = request
      request.headers.merge(with: headers, override: override)
      return request
    }
  }
  /// Modifier which sets request's single HTTP header.
  /// - parameter headerName: Name of HTTP header to be set.
  /// - parameter value: Value of HTTP header to be set.
  /// - parameter override: Determines if previous value will be overridden in case of conflict.
  /// On false current value will be preserved if it already exists or set otherwise.
  /// On true new value will be always set. Default is true.
  static func header<Value>(
    _ headerName: HTTPHeaderName,
    value: Value,
    override: Bool = true
  ) -> Self
  where Value: HTTPHeaderValue {
    Self { request, _ in
      guard request.headers[headerName] == nil as String? || override
      else { return request }
      var request = request
      request.headers[headerName] = value
      return request
    }
  }
  /// Modifier which sets request's HTTP body.
  /// - parameter body: HTTP body to be set. Errors thrown by this argument expression will be automatically converted to failures.
  /// - parameter override: Determines if previous body will be overridden in case of conflict.
  /// On false current body will be preserved if it already exists or set otherwise.
  /// On true new body will be always set. Default is true.
  static func body(
    _ body: @autoclosure @escaping () throws -> HTTPBody,
    override: Bool = true
  ) -> Self {
    Self { request, _ in
      guard request.body.isEmpty || override
      else { return request }
      var request = request
      request.body = try body()
      return request
    }
  }
}
