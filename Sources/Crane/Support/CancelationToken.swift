import struct Foundation.TimeInterval
import struct Foundation.Date

/// Cancelation token that can be used to cancel associated tasks.
public struct CancelationToken {
  
  private var status: () -> Bool
  private var cancelation: () -> Void
}

public extension CancelationToken {
  /// Cancelation status.
  var isCanceled: Bool { status() }
  /// Cancel tasks and change status to canceled.
  func cancel() { cancelation() }
}

public extension CancelationToken {
  /// Token which can become cancelled only when explicitly called.
  static var manual: Self {
    let status: Synchronized<Bool> = .witRecursiveLock(initialValue: false)
    return Self(
      status: { status.value },
      cancelation: { status.value = true }
    )
  }
  /// Token which can become cancelled when explicitly called.
  /// Takes closure executed on manual cancelation.
  /// - warning: You have to ensure that closure execution is thread safe.
  static func withClosure(
    _ closure: @escaping () -> Void
  ) -> Self {
    let closure: Synchronized<Optional<() -> Void>>
      = .witRecursiveLock(initialValue: closure)
    return Self(
      status: { closure.value == nil },
      cancelation: {
        closure { cancelation in
          cancelation?()
          cancelation = nil
        }
      })
  }
  /// Token which can become cancelled when explicitly called
  /// or automatically after timeout time.
  static func withTimeout(_ timeInterval: TimeInterval) -> Self {
    precondition(timeInterval > 0, "Cannot make timeout now or in past")
    return withDeadline(Date(timeIntervalSinceNow: timeInterval))
  }
  /// Token which can become cancelled when explicitly called
  /// or automatically after passing deadline.
  static func withDeadline(_ date: Date) -> Self {
    precondition(date.timeIntervalSinceNow > 0, "Cannot make deadline now or in past")
    let status: Synchronized<Bool> = .witRecursiveLock(initialValue: false)
    return Self(
      status: { status.value || date.timeIntervalSinceNow <= 0 },
      cancelation: { status.value = true }
    )
  }
  /// Token which combines given tokens.
  /// On manual cancel cancels all tokens.
  /// Is canceled only when all tokens are cancelled.
  static func combined(_ tokens: CancelationToken...) -> Self {
    combined(tokens)
  }
  /// Token which combines given tokens.
  /// On manual cancel cancels all tokens.
  /// Is canceled only when all tokens are cancelled.
  static func combined(_ tokens: Array<CancelationToken>) -> Self {
    assert(tokens.count > 1, "Cannot combine single or no token")
    return Self(
      status: { tokens.reduce(true, { $0 && $1.isCanceled }) },
      cancelation: { tokens.forEach { $0.cancel() } }
    )
  }
  /// Token which will never become cancelled.
  /// - warning: If you combine `never` cancelation token using `combined` function
  /// it will prevent returned (combined) token from being ever canceled.
  static var never: Self {
    Self(
      status: { false },
      cancelation: {}
    )
  }
  
  static var canceled: Self {
    Self(
      status: { true },
      cancelation: {}
    )
  }
}

#if canImport(Combine)

import protocol Combine.Cancellable

extension CancelationToken: Cancellable {}

#endif
