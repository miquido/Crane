#warning("TODO: fill docs")
public final class NetworkSession<Variable> {
  
  public let requestExecutor: HTTPRequestExecutor
  public var variable: Variable {
    get { variableGetter() }
    set { variableSetter(newValue) }
  }
  private var variableGetter: () -> Variable
  private var variableSetter: (Variable) -> Void
  
  internal init(
    requestExecutor: HTTPRequestExecutor,
    variableGetter: @escaping () -> Variable,
    variableSetter: @escaping (Variable) -> Void
  ) {
    self.requestExecutor = requestExecutor
    self.variableGetter = variableGetter
    self.variableSetter = variableSetter
  }
}

public extension NetworkSession {
  
  static func session(
    using requestExecutor: HTTPRequestExecutor,
    initialVariable variable: Variable,
    synchronized: Bool = true
  ) -> Self {
    let variableGetter: () -> Variable
    let variableSetter: (Variable) -> Void
    if synchronized {
      let synchronized = Synchronized.witRecursiveLock(initialValue: variable)
      variableGetter = { synchronized.value }
      variableSetter = { synchronized.value = $0 }
    } else {
      var variable = variable
      variableGetter = { variable }
      variableSetter = { variable = $0 }
    }
    return Self(
      requestExecutor: requestExecutor,
      variableGetter: variableGetter,
      variableSetter: variableSetter
    )
  }
  
  static func session(
    using requestExecutor: HTTPRequestExecutor,
    variableGetter: @escaping () -> Variable,
    variableSetter: @escaping (Variable) -> Void
  ) -> Self {
    Self(
      requestExecutor: requestExecutor,
      variableGetter: variableGetter,
      variableSetter: variableSetter
    )
  }
}

public extension NetworkSession {
  
  func withRequestModifier(_ modifier: HTTPRequestModifier<Variable>) -> Self {
    Self(
      requestExecutor: requestExecutor
        .withRequestModifier(
          modifier,
          using: self.variable
        ),
      variableGetter: self.variableGetter,
      variableSetter: self.variableSetter
    )
  }
  
  func withRequestModifier<Property>(
    using variableKeyPath: KeyPath<Variable, Property>,
    _ modifier: @escaping (Property) -> HTTPRequestModifier<Property>
  ) -> Self {
    Self(
      requestExecutor: requestExecutor
        .withRequestModifier(
          .withVariable(modifier),
          using: self.variable[keyPath: variableKeyPath]
        ),
      variableGetter: self.variableGetter,
      variableSetter: self.variableSetter
    )
  }
  
  func withResponseReader(_ reader: @escaping (Result<HTTPResponse, HTTPError>, inout Variable) -> Void) -> Self {
    Self(
      requestExecutor: requestExecutor
        .withResponseReader { result in
          reader(result, &self.variable)
        },
      variableGetter: self.variableGetter,
      variableSetter: self.variableSetter
    )
  }
}
