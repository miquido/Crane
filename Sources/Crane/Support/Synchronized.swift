import class Foundation.NSRecursiveLock
import class Foundation.DispatchQueue

internal final class Synchronized<Value> {
  
  private var synchronizedAccess: ((inout Value) -> Void) -> Value

  private init(
    synchronizedAccess: @escaping ((inout Value) -> Void) -> Value
  ) {
    self.synchronizedAccess = synchronizedAccess
  }
  
  internal var value: Value {
    get { self() }
    set { self { value in value = newValue } }
  }
}

internal extension Synchronized {
  
  @discardableResult func callAsFunction(
    _ access: (inout Value) -> Void = { _ in }
  ) -> Value {
    synchronizedAccess(access)
  }
}

// TODO: add version using stdatomic.h i.e. https://github.com/apple/swift-atomics or https://github.com/uber/swift-concurrency
internal extension Synchronized {
  
  static func witRecursiveLock(
    _ lock: NSRecursiveLock = NSRecursiveLock(),
    initialValue value: Value
  ) -> Self {
    var value: Value = value
    return Self { access in
      lock.lock()
      defer { lock.unlock() }
      access(&value)
      return value
    }
  }
}
