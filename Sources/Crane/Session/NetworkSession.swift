#warning("TODO: fill docs")
public final class NetworkSession<Variable> {
  
  public let requestExecutor: HTTPRequestExecutor
  public var variable: Variable {
    get { synchronizedVariable.value }
    set { synchronizedVariable.value = newValue }
  }
  private var synchronizedVariable: Synchronized<Variable>
  
  internal init(
    requestExecutor: HTTPRequestExecutor,
    synchronizedVariable: Synchronized<Variable>
  ) {
    self.requestExecutor = requestExecutor
    self.synchronizedVariable = synchronizedVariable
  }
}

public extension NetworkSession {
  
  static func session(
    using requestExecutor: HTTPRequestExecutor,
    initialVariable variable: Variable
  ) -> Self {
    Self(
      requestExecutor: requestExecutor,
      synchronizedVariable: Synchronized.witRecursiveLock(initialValue: variable)
    )
  }
}

public extension NetworkSession {
  
  func withRequestModifier(_ modifier: HTTPRequestModifier<Variable>) -> Self {
    Self(
      requestExecutor: requestExecutor.withRequestModifier(modifier, using: self.variable),
      synchronizedVariable: self.synchronizedVariable
    )
  }
  
  func withRequestModifier<Property>(
    using variableKeyPath: KeyPath<Variable, Property>,
    _ modifier: @escaping (Property) -> HTTPRequestModifier<Property>
  ) -> Self {
    Self(
      requestExecutor: requestExecutor.withRequestModifier(.withVariable(modifier), using: self.variable[keyPath: variableKeyPath]),
      synchronizedVariable: self.synchronizedVariable
    )
  }
}
