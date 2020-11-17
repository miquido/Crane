import struct Foundation.CharacterSet

/// Name of URL query item.
public struct URLQueryItemName: RawRepresentable {
  /// Raw string name of item.
  public var rawValue: String
  /// Initialize using raw string.
  /// - parameter rawValue: Raw string name.
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

public extension URLQueryItemName {
  /// Percent encoded name of query item.
  var percentEncodedQueryItemName: String {
    guard
      let percentEncodedQueryItemName = rawValue
        .addingPercentEncoding(
          withAllowedCharacters: urlQueryAllowedCharacterSet
        )
    else { fatalError("Failed to encode URL query item name") }
    return percentEncodedQueryItemName
  }
}

extension URLQueryItemName: Hashable {}

extension URLQueryItemName: ExpressibleByStringInterpolation {
  
  public init(stringLiteral value: String) {
    self.rawValue = value
  }
}

private let urlQueryAllowedCharacterSet
  = CharacterSet
  .urlQueryAllowed
  .subtracting(CharacterSet(charactersIn: "?="))
