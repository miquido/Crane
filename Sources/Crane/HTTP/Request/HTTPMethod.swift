/// Method of HTTP request.
public struct HTTPMethod: RawRepresentable {
  /// Raw string name of this method.
  public var rawValue: String
  /// Initialize using raw value.
  /// - parameter rawValue: Raw string name of this method.
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

extension HTTPMethod: Hashable {}

extension HTTPMethod: ExpressibleByStringLiteral {
  
  public init(stringLiteral value: String) {
    self.init(rawValue: value)
  }
}

// TODO: we could add description for common methods
public extension HTTPMethod {
  
  static let get: HTTPMethod = "GET"
  static let put: HTTPMethod = "PUT"
  static let post: HTTPMethod = "POST"
  static let patch: HTTPMethod = "PATCH"
  static let delete: HTTPMethod = "DELETE"
  static let options: HTTPMethod = "OPTIONS"
  static let head: HTTPMethod = "HEAD"
}
