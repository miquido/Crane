#warning("TODO: fill docs")
public struct NetworkRequestTemplate<Variables> {
  
  private var modifiers: Array<HTTPRequestModifier<Variables>> = []
  /// Initialize with given modifiers.
  /// - parameter modifiers: Modifiers applied by this template.
  /// - warning: Please note that in case of conflicting modifiers last applied will override previous one.
  public init(_ modifiers: HTTPRequestModifier<Variables>...) {
    self.modifiers = modifiers
  }
  
  public init<Modifiers>(_ modifiers: Modifiers)
  where Modifiers: Collection, Modifiers.Element == HTTPRequestModifier<Variables> {
    self.modifiers = Array(modifiers)
  }
}

internal extension NetworkRequestTemplate {
  /// Append modifiers to this template.
  /// - parameter modifiers: Modifiers appended to this template.
  /// - warning: Please note that in case of conflicting modifiers last applied will override previous one.
  mutating func append(_ modifiers: HTTPRequestModifier<Variables>...) {
    self.modifiers.append(contentsOf: modifiers)
  }
  /// Append modifiers to this template.
  /// - parameter modifiers: Modifiers appended to this template.
  /// - warning: Please note that in case of conflicting modifiers last applied will override previous one.
  mutating func append<Modifiers>(_ modifiers: Modifiers)
  where Modifiers: Sequence, Modifiers.Element == HTTPRequestModifier<Variables> {
    self.modifiers.append(contentsOf: modifiers)
  }
  /// Make new template by appending provided modifiers to this template.
  /// - parameter modifiers: Modifiers to be appended.
  /// - warning: Please note that in case of conflicting modifiers last applied will override previous one.
  func appending(_ modifiers: HTTPRequestModifier<Variables>...) -> Self {
    var copy = self
    copy.modifiers.append(contentsOf: modifiers)
    return copy
  }
  /// Make new template by appending provided modifiers to this template.
  /// - parameter modifiers: Modifiers to be appended.
  /// - warning: Please note that in case of conflicting modifiers last applied will override previous one.
  func appending<Modifiers>(_ modifiers: Modifiers) -> Self
  where Modifiers: Sequence, Modifiers.Element == HTTPRequestModifier<Variables> {
    var copy = self
    copy.modifiers.append(contentsOf: modifiers)
    return copy
  }
}

public extension NetworkRequestTemplate {
  /// Make HTTPRequest instance by applying template modifiers with provided parameter store.
  /// - parameter parameterStore: Parameter store used by template modifiers to produce request.
  /// - returns: Result of making request instance with given parameter store.
  /// Fails if any of template modifiers fails.
  func request(
    with variables: Variables
  ) -> Result<HTTPRequest, Error> {
    var request = HTTPRequest()
    for modifier in modifiers {
      switch modifier(appliedOn: request, using: variables) {
      case let .success(modifiedRequest):
        request = modifiedRequest
      case let .failure(error):
        return .failure(error)
      }
    }
    return .success(request)
  }
}
