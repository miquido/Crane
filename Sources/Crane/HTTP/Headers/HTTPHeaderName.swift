/// Name of HTTP header field. Please note that HTTP header names are case insensitive
/// so 'header' and 'HEADER' are treated as same field name.
public struct HTTPHeaderName: RawRepresentable {
  /// Raw string name of header field.
  public var rawValue: String
  /// Initialize using raw string.
  /// - parameter rawValue: Raw string name.
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

extension HTTPHeaderName: Hashable {
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.rawValue.lowercased())
  }
  
  public static func == (
    _ lhs: HTTPHeaderName,
    _ rhs: HTTPHeaderName
  ) -> Bool {
    lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
  }
}

extension HTTPHeaderName: ExpressibleByStringInterpolation {
  
  public init(stringLiteral value: String) {
    self.rawValue = value
  }
}

// TODO: we could add description for common header names
public extension HTTPHeaderName {
  
  static let host: HTTPHeaderName = "Host"
  static let server: HTTPHeaderName = "Server"
  static let referer: HTTPHeaderName = "Referer"
  static let connection: HTTPHeaderName = "Connection"
  static let userAgent: HTTPHeaderName = "User-Agent"
  static let date: HTTPHeaderName = "Date"
  static let authorization: HTTPHeaderName = "Authorization"
  static let cookie: HTTPHeaderName = "Cookie"
  static let setCookie: HTTPHeaderName = "Set-Cookie"
  static let cacheControl: HTTPHeaderName = "Cache-Control"
  static let contentType: HTTPHeaderName = "Content-Type"
  static let contentLength: HTTPHeaderName = "Content-Length"
  static let contentEncoding: HTTPHeaderName = "Content-Encoding"
  static let contentLanguage: HTTPHeaderName = "Content-Language"
  static let acceptCharset: HTTPHeaderName = "Accept-Charset"
  static let acceptEncoding: HTTPHeaderName = "Accept-Encoding"
  static let acceptLanguage: HTTPHeaderName = "Accept-Language"
}
