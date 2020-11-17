/// Type describing errors for given network request or connection.
public protocol NetworkError: Error {
  
  static func httpError(_ httpError: HTTPError) -> Self
  static func encodingFailed(_ reason: Error?) -> Self
  static func decodingFailed(_ reason: Error?) -> Self
  static var canceled: Self { get }
  
  var isCanceled: Bool { get }
}
