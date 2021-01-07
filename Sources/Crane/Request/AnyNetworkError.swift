public enum AnyNetworkError: NetworkError {

  public static func fromHTTPError(_ httpError: HTTPError) -> Self { .httpError(httpError) }
  public static func fromRequestEncodingFailure(reason: Error?) -> Self { .requestEncodingFailed(reason: reason) }
  public static func fromResponseDecodingFailure(reason: Error?) -> Self { .responseDecodingFailed(reason: reason) }
  
  case httpError(HTTPError)
  case requestEncodingFailed(reason: Error?)
  case responseDecodingFailed(reason: Error?)
  case canceled
  
  public var isCanceled: Bool {
    switch self {
    case .canceled, .httpError(.canceled):
      return true
    case _:
      return false
    }
  }
}
