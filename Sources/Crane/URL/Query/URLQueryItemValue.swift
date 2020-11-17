import struct Foundation.CharacterSet

/// Any value of URL query item. It has to be represented by string in a lossless, unambiguous way.
/// Any `LosslessStringConvertible` type gains implementation automatically when conforming to this protocol.
public protocol URLQueryItemValue {
  /// Initialize using string representation if able.
  /// - parameter queryItemValue: String representation of this value.
  init?(queryItemValue: String)
  /// String representation of this value.
  var queryItemValue: String { get }
}

public extension URLQueryItemValue {
  /// Percent encoded string representation of this value.
  var percentEncodedQueryItemValue: String {
    guard
      let percentEncodedQueryItemValue = queryItemValue
        .addingPercentEncoding(
          withAllowedCharacters: urlQueryAllowedCharacterSet
        )
    else { fatalError("Failed to encode URL query item value") }
    return percentEncodedQueryItemValue
  }
}

extension URLQueryItemValue where Self: LosslessStringConvertible {
  
  public init?(queryItemValue: String) {
    self.init(queryItemValue)
  }
  
  public var queryItemValue: String { description }
}

extension Bool: URLQueryItemValue {}
extension String: URLQueryItemValue {} // TODO: should we split over ',' and preserve it encode it or ignore?
extension Substring: URLQueryItemValue {}
extension StaticString: URLQueryItemValue {
  
  public init?(queryItemValue: String) { fatalError("Unreachable") }
  
  public var queryItemValue: String { description }
}
extension UInt: URLQueryItemValue {}
extension UInt8: URLQueryItemValue {}
extension UInt16: URLQueryItemValue {}
extension UInt32: URLQueryItemValue {}
extension UInt64: URLQueryItemValue {}
extension Int: URLQueryItemValue {}
extension Int8: URLQueryItemValue {}
extension Int16: URLQueryItemValue {}
extension Int32: URLQueryItemValue {}
extension Int64: URLQueryItemValue {}
extension Float: URLQueryItemValue {}
extension Double: URLQueryItemValue {}

#warning("TODO: verify if just ',' is separator")
extension Array: URLQueryItemValue where Element: URLQueryItemValue {
  
  public init?(queryItemValue: String) {
    self = queryItemValue
      .split(separator: ",")
      .compactMap { Element.init(queryItemValue: $0.trimmingCharacters(in: .whitespaces)) }
  }

  public var queryItemValue: String {
    var result: String = String()
    for (idx, element) in self.enumerated() {
      if idx.distance(to: self.endIndex) > 1 {
        result += element.queryItemValue + ","
      } else {
        result += element.queryItemValue
      }
    }
    return result
  }
}

private let urlQueryAllowedCharacterSet
  = CharacterSet
  .urlQueryAllowed
  .subtracting(CharacterSet(charactersIn: "?="))
