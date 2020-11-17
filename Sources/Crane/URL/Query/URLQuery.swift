import struct Foundation.URLQueryItem

/// Query component of URL.
public struct URLQuery {
  /// Returns true if there is no query at all.
  public var isEmpty: Bool { dictionary.isEmpty }
  private var dictionary: Dictionary<URLQueryItemName, URLQueryItemValue>
  
  internal init(_ dictionary: Dictionary<URLQueryItemName, URLQueryItemValue>) {
    self.dictionary = dictionary
  }
}

public extension URLQuery {
  /// Initialize using raw dictionary (with string names and values).
  /// - parameter rawDictionary: Raw dictionary to convert to query.
  /// String values will be converted to Int/Double/Bool if able.
  /// - warning: Multiple values and custom types are not supported by this initializer.
  /// Please do the conversion manually if needed.
  init(rawDictionary: Dictionary<String, String>) {
    // TODO: add support for Arrays of values
    self.dictionary = Dictionary<URLQueryItemName, URLQueryItemValue>(
      uniqueKeysWithValues:
        rawDictionary
        .compactMap { (queryItem: (name: String, value: String)) -> (URLQueryItemName, URLQueryItemValue)? in
          guard
            let value: URLQueryItemValue
            = Int(queryItemValue: queryItem.value)
            ?? Double(queryItemValue: queryItem.value)
            ?? Bool(queryItemValue: queryItem.value)
            ?? String(queryItemValue: queryItem.value)
          else { return nil }
          return (URLQueryItemName(rawValue: queryItem.name), value)
      }
    )
  }
  /// Make raw dictionary (with string names and values) representation of this query.
  var rawDictionary: Dictionary<String, String> {
    Dictionary<String, String>(
      uniqueKeysWithValues:
        dictionary
          .map { (queryItem: (name: URLQueryItemName, value: URLQueryItemValue)) -> (String, String) in
            (queryItem.name.rawValue, queryItem.value.queryItemValue)
          }
    )
  }
}
public extension URLQuery {
  /// Initialize form Foundation URLQueryItem sequence.
  /// - parameter items: Query items to initialize from.
  init<Items>(_ items: Items)
  where Items: Sequence, Items.Element == URLQueryItem {
    self.dictionary = Dictionary<URLQueryItemName, URLQueryItemValue>(
      uniqueKeysWithValues:
      items
      .compactMap { (queryItem: URLQueryItem) -> (URLQueryItemName, URLQueryItemValue)? in
          guard
            let rawValue = queryItem.value,
            let value: URLQueryItemValue = String(queryItemValue: rawValue)
          else { return nil }
          return (URLQueryItemName(rawValue: queryItem.name), value)
      }
    )
  }
}

public extension URLQuery {
  /// Percent encoded string representation of this query.
  var percentEncodedString: String? {
    guard !dictionary.isEmpty else { return nil }
    return dictionary.reduce(into: "") { (result: inout String, item: (name: URLQueryItemName, value: URLQueryItemValue)) in
      if !result.isEmpty {
        result.append("&")
      } else { /* */ }
      result.append("\(item.name.percentEncodedQueryItemName)=\(item.value.percentEncodedQueryItemValue)")
    }
  }
}

public extension URLQuery {
  /// Access query item value by its name.
  subscript<Value: URLQueryItemValue>(_ name: URLQueryItemName) -> Value? {
    get { dictionary[name].flatMap { Value(queryItemValue: $0.queryItemValue) } }
    set { dictionary[name] = newValue }
  }
}

public extension URLQuery {
  // Merge this query set with other one.
  /// - parameter other: Other query to merge with.
  /// - parameter override: Specifies if conflicting values will be overridden by values from other.
  mutating func merge(
    with other: URLQuery,
    override: Bool = true
  ) {
    self.dictionary.merge(other.dictionary, uniquingKeysWith: { override ? $1 : $0 })
  }
  /// Make new query by merging this query with other one.
  /// - parameter other: Other query to merge with.
  /// - parameter override: Specifies if conflicting values will be overridden by values from other.
  func merging(
    with other: URLQuery,
    override: Bool = true
  ) -> URLQuery {
    var copy = self
    copy.merge(with: other, override: override)
    return copy
  }
}

public extension URLQuery {
  /// Makes empty URL query.
  static var empty: URLQuery { [:] }
}

extension URLQuery: ExpressibleByDictionaryLiteral {
  
  public init(dictionaryLiteral: (URLQueryItemName, URLQueryItemValue)...) {
    self.dictionary = Dictionary<URLQueryItemName, URLQueryItemValue>(
      uniqueKeysWithValues: dictionaryLiteral
    )
  }
}

extension URLQuery: ExpressibleByArrayLiteral {
  
  public init(arrayLiteral: URLQueryItem...) {
    self.dictionary = Dictionary<URLQueryItemName, URLQueryItemValue>(
      uniqueKeysWithValues:
        arrayLiteral
        .compactMap { (queryItem: URLQueryItem) -> (URLQueryItemName, URLQueryItemValue)? in
          guard
            let rawValue = queryItem.value,
            let value: URLQueryItemValue = String(queryItemValue: rawValue)
          else { return nil }
          return (URLQueryItemName(rawValue: queryItem.name), value)
        }
    )
  }
}

extension URLQuery: CustomStringConvertible {
  public var description: String { percentEncodedString ?? "" }
}
