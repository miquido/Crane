import struct Foundation.UUID

public extension NetworkRequest {
  
  func withLogs(_ logger: @escaping (String) -> Void) -> Self {
    Self { arguments, cancelation, completion in
      let trackingID = UUID()
      logger("[\(trackingID)] Executing request \(Self.self) with \(arguments)")
      return self(
        arguments,
        cancelation: cancelation,
        completion: { result in
          switch result {
          case let .success(response):
            logger("[\(trackingID)] Received \(response) for \(Self.self) with \(arguments)")
          case let .failure(error):
            logger("[\(trackingID)] \(Self.self) with \(arguments) failed with \(error)")
          }
          completion(result)
        }
      )
    }
  }
}
