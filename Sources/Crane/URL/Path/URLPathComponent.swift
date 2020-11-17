import struct Foundation.CharacterSet

/// Single component of URL path.
/// Any `LosslessStringConvertible` type gains implementation automatically when conforming to this protocol.
public protocol URLPathComponent {
  /// Single, percent encoded string component of URL path.
  /// - warning: It has not to begin or end with '/' character.
  var percentEncodedPathComponent: String { get }
}

extension URLPathComponent where Self: LosslessStringConvertible {
  #warning("TODO: verify escaping and encoding")
  public var percentEncodedPathComponent: String {
    var pathComponent = self.description
    if pathComponent.hasPrefix("/") {
      pathComponent = String(pathComponent.dropFirst())
    } else { /* */ }
    guard
      let percentEncodedPathComponent = pathComponent
      .addingPercentEncoding(
        withAllowedCharacters: urlPathComponentAllowedCharacterSet
      )
    else { fatalError("Failed to encode URLPath component") }
    return percentEncodedPathComponent
  }
}

extension Bool: URLPathComponent {}
extension String: URLPathComponent {
  // It is kind of exception since it is not a single component but it significantly improves usage while still being intuitive and feeling natural.
  public var percentEncodedPathComponent: String {
    String(
      description
        .split(separator: "/")
        .reduce(into: "", { $0.append("/\($1)") })
        .drop(while: { $0 == "/"}) // removes leading '/' characters
    )
  }
}
extension Substring: URLPathComponent {
  // It is kind of exception since it is not a single component but it significantly improves usage while still being intuitive and feeling natural.
  public var percentEncodedPathComponent: String {
    String(
      description
        .split(separator: "/")
        .reduce(into: "", { $0.append("/\($1)") })
        .drop(while: { $0 == "/"}) // removes leading '/' characters
    )
  }
}
extension StaticString: URLPathComponent {
  // It is kind of exception since it is not a single component but it significantly improves usage while still being intuitive and feeling natural.
  public var percentEncodedPathComponent: String {
    String(
      description
        .split(separator: "/")
        .reduce(into: "", { $0.append("/\($1.percentEncodedPathComponent)") })
        .drop(while: { $0 == "/"}) // removes leading '/' characters
    )
  }
}
extension UInt: URLPathComponent {}
extension UInt8: URLPathComponent {}
extension UInt16: URLPathComponent {}
extension UInt32: URLPathComponent {}
extension UInt64: URLPathComponent {}
extension Int: URLPathComponent {}
extension Int8: URLPathComponent {}
extension Int16: URLPathComponent {}
extension Int32: URLPathComponent {}
extension Int64: URLPathComponent {}
extension Float: URLPathComponent {}
extension Double: URLPathComponent {}

private let urlPathComponentAllowedCharacterSet
  = CharacterSet
  .urlPathAllowed
  .subtracting(CharacterSet(charactersIn: "/"))
