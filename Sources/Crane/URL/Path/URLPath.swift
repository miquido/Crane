/// Path component of URL.
public struct URLPath {
  /// Returns true if there is no path at all.
  public var isEmpty: Bool { percentEncodedString.isEmpty }
  /// Percent encoded string representation of this path.
  public private(set) var percentEncodedString: String
  /// Initialize using any number of path components.
  public init(_ components: URLPathComponent...) {
    self.percentEncodedString = components
      .reduce(into: "") {
        $0.append("/\($1.percentEncodedPathComponent)")
      }
  }
}

public extension URLPath {
  /// Append component at the end of this path.
  /// - parameter component: Component to append.
  mutating func append(_ component: URLPathComponent) {
    percentEncodedString.append("/\(component.percentEncodedPathComponent)")
  }
  /// Make a copy of this path appending component at the end of it.
  /// - parameter component: Component to append.
  func appending(_ component: URLPathComponent) -> Self {
    var copy = self
    copy.append(component)
    return copy
  }
  /// Append other path at the end of this path.
  /// - parameter other: Other path to append.
  mutating func append(_ other: Self) {
    percentEncodedString.append(other.percentEncodedString)
  }
  /// Make a copy of this path appending other path at the end of it.
  /// - parameter other: Other path to append.
  func appending(_ other: Self) -> Self {
    var copy = self
    copy.append(other)
    return copy
  }
  /// Prepend component at the start of this path.
  /// - parameter component: Component to prepend.
  mutating func prepend(_ component: URLPathComponent) {
    percentEncodedString = "/\(component.percentEncodedPathComponent)"
      .appending(percentEncodedString)
  }
  /// Make a copy of this path prepending component at the start of it.
  /// - parameter component: Component to prepend.
  func prepending(_ component: URLPathComponent) -> Self {
    var copy = self
    copy.prepend(component)
    return copy
  }
  /// Prepend other path at the start of this path.
  /// - parameter other: Other path to prepend.
  mutating func prepend(_ other: Self) {
    percentEncodedString = other
      .percentEncodedString
      .appending(percentEncodedString)
  }
  /// Make a copy of this path prepending other path at the start of it.
  /// - parameter other: Other path to prepend.
  func prepending(_ other: Self) -> Self {
    var copy = self
    copy.prepend(other)
    return copy
  }
}

extension URLPath: CustomStringConvertible {
  
  public var description: String { percentEncodedString }
}

extension URLPath: ExpressibleByStringInterpolation {
  
  public init(stringLiteral: String) {
    if stringLiteral.description.isEmpty {
      self.percentEncodedString = ""
    } else {
      self.percentEncodedString = "/\(stringLiteral.percentEncodedPathComponent)"
    }
  }
}

extension URLPath: ExpressibleByArrayLiteral {
  
  public init(arrayLiteral components: URLPathComponent...) {
    self.percentEncodedString = components
      .reduce(into: "") {
        $0.append("/\($1.percentEncodedPathComponent)")
      }
  }
}
