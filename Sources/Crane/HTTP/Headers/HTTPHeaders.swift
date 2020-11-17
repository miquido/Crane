/// Set of HTTP headers.
public struct HTTPHeaders {
  /// Returns true if there is no headers at all.
  public var isEmpty: Bool { dictionary.isEmpty }
  private var dictionary: Dictionary<HTTPHeaderName, HTTPHeaderValue>
  
  internal init(_ dictionary: Dictionary<HTTPHeaderName, HTTPHeaderValue>) {
    self.dictionary = dictionary
  }
}

public extension HTTPHeaders {
  /// Initialize using raw dictionary (with string names and values).
  /// - parameter rawDictionary: Raw dictionary to convert to headers.
  /// String values will be converted to Int/Double/Bool if able.
  /// - warning: Multiple values and custom types are not supported by this initializer.
  /// Please do the conversion manually if needed.
  init(rawDictionary: Dictionary<String, String>) {
    // TODO: add support for Arrays of values
    self.dictionary = Dictionary<HTTPHeaderName, HTTPHeaderValue>(
      uniqueKeysWithValues:
        rawDictionary
          .compactMap { (header: (name: String, value: String)) -> (HTTPHeaderName, HTTPHeaderValue)? in
            guard
              let value: HTTPHeaderValue
              = Int(httpHeaderValue: header.value)
              ?? Double(httpHeaderValue: header.value)
              ?? Bool(httpHeaderValue: header.value)
              ?? String(httpHeaderValue: header.value)
            else { return nil }
            return (HTTPHeaderName(rawValue: header.name), value)
          }
    )
  }
  /// Make raw dictionary (with string names and values) representation of this headers.
  var rawDictionary: Dictionary<String, String> {
    Dictionary<String, String>(
    uniqueKeysWithValues:
      dictionary
        .map { (header: (name: HTTPHeaderName, value: HTTPHeaderValue)) -> (String, String) in
          (header.name.rawValue, header.value.httpHeaderValue)
        }
    )
  }
}

public extension HTTPHeaders {
  /// Access header value by its name.
  /// - warning: Please note that HTTP header names are case insensitive
  /// so 'header' and 'HEADER' are treated as same field name.
  subscript<Value: HTTPHeaderValue>(_ name: HTTPHeaderName) -> Value? {
    get {
      dictionary[name]
        .flatMap {
          $0 as? Value ?? Value(httpHeaderValue: $0.httpHeaderValue)
        }
    }
    set { dictionary[name] = newValue }
  }
}

public extension HTTPHeaders {
  /// Merge this headers set with other one.
  /// - parameter other: Other headers to merge with.
  /// - parameter override: Specifies if conflicting values will be overridden by values from other.
  mutating func merge(
    with other: HTTPHeaders,
    override: Bool = true
  ) {
    self.dictionary.merge(other.dictionary, uniquingKeysWith: { override ? $1 : $0 })
  }
  /// Make new headers by merging this headers with other one.
  /// - parameter other: Other headers to merge with.
  /// - parameter override: Specifies if conflicting values will be overridden by values from other.
  func merging(
    with other: HTTPHeaders,
    override: Bool = true
  ) -> HTTPHeaders {
    var copy = self
    copy.merge(with: other, override: override)
    return copy
  }
}

public extension HTTPHeaders {
  /// Makes empty HTTP headers.
  static var empty: HTTPHeaders { HTTPHeaders() }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
  
  public init(dictionaryLiteral: (HTTPHeaderName, HTTPHeaderValue)...) {
    self.dictionary = .init(uniqueKeysWithValues: dictionaryLiteral)
  }
}

extension HTTPHeaders: CustomStringConvertible {
  
  public var description: String { dictionary.description }
}
