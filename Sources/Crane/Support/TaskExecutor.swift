import struct Foundation.TimeInterval
import class Foundation.OperationQueue
import class Foundation.BlockOperation
import Dispatch

public struct TaskExecutor {
  
  public var execute: (
    TimeInterval,
    CancelationToken,
    @escaping (CancelationToken) -> Void
  ) -> CancelationToken
}

public extension TaskExecutor {
  
  @discardableResult func callAsFunction(
    after: TimeInterval = 0,
    cancelation: CancelationToken = .manual,
    execute task: @escaping (CancelationToken) -> Void
  ) -> CancelationToken {
    execute(after, cancelation, task)
  }
}

public extension TaskExecutor {
  
  static var main: Self {
    dispatchQueue(.main)
  }
  
  static var background: Self {
    dispatchQueue(backgroundQueue)
  }
  
  static func dispatchQueue(_ queue: DispatchQueue) -> Self {
    Self { delay, cancelation, task in
      queue.asyncAfter(
        deadline: .after(delay)
      ) {
        task(cancelation)
      }
      return cancelation
    }
  }
}


private let backgroundQueue = DispatchQueue(label: "crane.background")

private extension DispatchTime {
  
  static func after(_ timeInterval: TimeInterval) -> Self {
    DispatchTime.now() + timeInterval
  }
}
