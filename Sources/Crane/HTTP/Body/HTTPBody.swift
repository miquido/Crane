import struct Foundation.Data

/// Wrapper around raw HTTP body data.
public struct HTTPBody: RawRepresentable {
  /// Raw data of this body.
  public var rawValue: Data
  /// Initialize using raw value.
  /// - parameter rawValue: Raw data of this body.
  public init(rawValue: Data = Data()) {
    self.rawValue = rawValue
  }
  /// Returns true if there is no data at all.
  public var isEmpty: Bool { rawValue.isEmpty }
}

public extension HTTPBody {
  /// Append raw data at the end of this body.
  /// - parameter data: Data to append.
  mutating func append(_ data: Data) {
    rawValue.append(data)
  }
  /// Make a copy of this body appending raw data at the end of it.
  /// - parameter data: Data to append.
  func appending(_ data: Data) -> Self {
    var copy = self
    copy.append(data)
    return copy
  }
}

public extension HTTPBody {
  /// Makes empty HTTP body.
  static var empty: HTTPBody { HTTPBody() }
}
