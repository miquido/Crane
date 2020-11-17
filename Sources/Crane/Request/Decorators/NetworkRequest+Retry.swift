import struct Foundation.TimeInterval

public extension NetworkRequest {
  
  func withAutoRetry(
    maxRetryCount: UInt = 3,
    on executor: TaskExecutor = .background
  ) -> Self {
    Self { arguments, cancelation, completion in
      func executeWithAutoRetry(
        cancelation: CancelationToken,
        triesLeft: UInt
      ) -> CancelationToken {
        self(
          arguments,
          cancelation: cancelation,
          completion: { result in
            if case let .failure(reason) = result, !reason.isCanceled, triesLeft > 0 {
              #warning("TODO: Add delay based on response")
              executor(
                after: TimeInterval.random(in: 2 ... 5),
                cancelation: cancelation
              ) { cancelation in
                // cancelation system allows us to drop returned value - initially provided cancelation will be used for all tries
                _ = executeWithAutoRetry(cancelation: cancelation, triesLeft: triesLeft - 1)
              }
            } else {
              completion(result)
            }
        })
      }
      return executeWithAutoRetry(cancelation: cancelation, triesLeft: maxRetryCount)
    }
  }
}
