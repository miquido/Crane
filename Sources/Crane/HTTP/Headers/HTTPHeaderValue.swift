/// Any value of HTTP header. It has to be represented by string in a lossless, unambiguous way.
/// Any `LosslessStringConvertible` type gains implementation automatically when conforming to this protocol.
public protocol HTTPHeaderValue {
  /// Initialize using string representation if able.
  /// - parameter httpHeaderValue: String representation of this value.
  init?(httpHeaderValue: String)
  /// String representation of this value.
  var httpHeaderValue: String { get }
}

extension HTTPHeaderValue where Self: LosslessStringConvertible {
  
  public init?(httpHeaderValue: String) {
    self.init(httpHeaderValue)
  }
  
  public var httpHeaderValue: String { description }
}

extension Bool: HTTPHeaderValue {}
extension String: HTTPHeaderValue {}
extension Substring: HTTPHeaderValue {}
extension StaticString: HTTPHeaderValue {
  
  public init?(httpHeaderValue: String) { fatalError("Unreachable") }
  
  public var httpHeaderValue: String { description }
}
extension UInt: HTTPHeaderValue {}
extension UInt8: HTTPHeaderValue {}
extension UInt16: HTTPHeaderValue {}
extension UInt32: HTTPHeaderValue {}
extension UInt64: HTTPHeaderValue {}
extension Int: HTTPHeaderValue {}
extension Int8: HTTPHeaderValue {}
extension Int16: HTTPHeaderValue {}
extension Int32: HTTPHeaderValue {}
extension Int64: HTTPHeaderValue {}
extension Float: HTTPHeaderValue {}
extension Double: HTTPHeaderValue {}

#warning("TODO: verify if just ';' is separator")
extension Array: HTTPHeaderValue where Element: HTTPHeaderValue {
  
  public init?(httpHeaderValue: String) {
    let splited = httpHeaderValue.split(separator: ";")
    guard !splited.isEmpty else { return nil }
    self = splited
      .compactMap {
        Element(httpHeaderValue: $0.trimmingCharacters(in: .whitespaces))
      }
  }

  public var httpHeaderValue: String {
    var result: String = String()
    for (idx, element) in self.enumerated() {
      if idx.distance(to: self.endIndex) > 1 {
        result += element.httpHeaderValue + "; "
      } else {
        result += element.httpHeaderValue
      }
    }
    return result
  }
}
