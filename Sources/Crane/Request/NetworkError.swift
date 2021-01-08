/// Type describing errors for network requests.
public struct NetworkError: Error {
  
  public let identifier: Identifier
  public let underlyingError: Error?
  public let isCanceled: Bool
  public var extensions: Dictionary<Extension, Any>
  
  public init(
    identifier: Identifier,
    underlyingError: Error? = nil,
    extensions: Dictionary<Extension, Any> = [:]
  ) {
    self.init(
      identifier: identifier,
      underlyingError: underlyingError,
      extensions: extensions,
      isCanceled: false
    )
  }
  
  fileprivate init(
    identifier: Identifier,
    underlyingError: Error? = nil,
    extensions: Dictionary<Extension, Any> = [:],
    isCanceled: Bool = false
  ) {
    self.identifier = identifier
    self.underlyingError = underlyingError
    self.extensions = extensions
    self.isCanceled = isCanceled
  }
  
  public func with(
    extensions: Dictionary<Extension, Any>,
    overrideDuplicates: Bool = true
  ) -> Self {
    Self(
      identifier: identifier,
      underlyingError: underlyingError,
      extensions: self.extensions.merging(extensions, uniquingKeysWith: { overrideDuplicates ? $1 : $0 }),
      isCanceled: isCanceled
    )
  }
}

public extension NetworkError {
  
  struct Identifier: RawRepresentable, Hashable, ExpressibleByStringLiteral, LosslessStringConvertible {
    
    public let rawValue: String
    
    public init(rawValue: String) {
      self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
      self.init(rawValue: value)
    }
    
    public init?(_ description: String) {
      self.init(rawValue: description)
    }
    
    public var description: String { rawValue }
  }
  
  struct Extension: RawRepresentable, Hashable, ExpressibleByStringLiteral, LosslessStringConvertible {
    
    public let rawValue: String
    
    public init(rawValue: String) {
      self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
      self.init(rawValue: value)
    }
    
    public init?(_ description: String) {
      self.init(rawValue: description)
    }
    
    public var description: String { rawValue }
  }
}

public extension NetworkError.Identifier {
  
  static let httpError: Self = "httpError"
  static let requestEncodingFailure: Self = "requestEncodingFailure"
  static let connectionFailed: Self = "connectionFailed"
  static let responseDecodingFailure: Self = "responseDecodingFailure"
  static let unauthorized: Self = "unauthorized"
  static let canceled: Self = "canceled"
}

public extension NetworkError.Extension {
  
  static let requestVariables: Self = "requestVariables"
  static let httpRequest: Self = "httpRequest"
  static let httpResponse: Self = "httpResponse"
}

public extension NetworkError {

  static func httpError(
    _ httpError: HTTPError,
    extensions: Dictionary<Extension, Any> = [:]
  ) -> Self {
    
    switch httpError {
    case .canceled:
      return .canceled(extensions: extensions)
    case .cannotConnect:
      return .connectionFailed(reason: httpError, extensions: extensions)
    case _: // it might be a good idea to map all instead of wrap http errors
      return Self(
        identifier: .httpError,
        underlyingError: httpError,
        extensions: extensions,
        isCanceled: false
      )
    }
  }
  
  static func requestEncodingFailure(
    reason: Error? = nil,
    extensions: Dictionary<Extension, Any> = [:]
  ) -> Self {
    Self(
      identifier: .requestEncodingFailure,
      underlyingError: reason,
      extensions: extensions,
      isCanceled: false
    )
  }
  
  static func connectionFailed(
    reason: Error? = nil,
    extensions: Dictionary<Extension, Any> = [:]
  ) -> Self {
    Self(
      identifier: .connectionFailed,
      underlyingError: reason,
      extensions: extensions,
      isCanceled: false
    )
  }
  
  static func responseDecodingFailure(
    reason: Error? = nil,
    extensions: Dictionary<Extension, Any> = [:]
  ) -> Self {
    Self(
      identifier: .responseDecodingFailure,
      underlyingError: reason,
      extensions: extensions,
      isCanceled: false
    )
  }
  
  static func unauthorized(
    reason: Error? = nil,
    extensions: Dictionary<Extension, Any> = [:]
  ) -> Self {
    Self(
      identifier: .unauthorized,
      underlyingError: reason,
      extensions: extensions,
      isCanceled: false
    )
  }
  
  static func canceled(extensions: Dictionary<Extension, Any> = [:]) -> Self {
    Self(
      identifier: .canceled,
      underlyingError: nil,
      extensions: extensions,
      isCanceled: true
    )
  }
}

extension NetworkError: CustomStringConvertible {
  
  public var description: String {
    """
    --- NetworkError: \(identifier)
    IsCanceled: \(isCanceled)
    UnderlyingError: \(underlyingError.map { "\($0)" } ?? "N/A")
    Extensions: \(extensions.reduce(into: "", { $0 += "\n- \($1.key): \($1.value)" }))
    ---
    """
  }
}
