public enum AnyNetworkError: NetworkError {

  case httpError(HTTPError)
  case encodingFailed(Error?)
  case decodingFailed(Error?)
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