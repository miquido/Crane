public extension NetworkRequest {
  
  func withCallback(on executor: TaskExecutor) -> Self {
    Self { variable, cancelation, completion in
      self(
        variable,
        cancelation: cancelation,
        completion: { result in
          executor(cancelation: cancelation) { cancelation in
            guard !cancelation.isCanceled
            else { return completion(.failure(.canceled())) }
            completion(result)
          }
        }
      )
    }
  }
}
