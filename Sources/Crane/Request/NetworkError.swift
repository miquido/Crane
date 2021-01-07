/// Type describing errors for given network request or connection.
public protocol NetworkError: Error {
  
  static func fromHTTPError(_ httpError: HTTPError) -> Self
  static func fromRequestEncodingFailure(reason: Error?) -> Self
  static func fromResponseDecodingFailure(reason: Error?) -> Self
  static var canceled: Self { get }
  
  var isCanceled: Bool { get }
}
