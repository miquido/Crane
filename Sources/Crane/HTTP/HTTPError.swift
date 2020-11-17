/// Error associated with execution of HTTPRequest.
public enum HTTPError: Error {
  // TODO: we might add description for those reasons and add any other common ones.
  case invalidRequest
  case invalidResponse
  case timeout
  case cannotConnect
  case canceled
  case other(Error)
}
