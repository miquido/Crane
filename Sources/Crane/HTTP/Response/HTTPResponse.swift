import struct Foundation.Data
import struct Foundation.URL
import class Foundation.URLResponse
import class Foundation.HTTPURLResponse

/// HTTPResponse abstraction.
public struct HTTPResponse {
  /// URL of this response.
  public var url: URL
  /// HTTP status code of this response.
  public var statusCode: HTTPStatusCode
  /// All headers associated with this response.
  public var headers: HTTPHeaders
  /// Body associated with this response.
  public var body: HTTPBody
  /// Initialize by providing all response fields.
  /// - parameter url: URL of this response.
  /// - parameter statusCode: HTTP status code of this response.
  /// - parameter headers: All headers associated with this response.
  /// - parameter body: Body associated with this response.
  public init(
    url: URL,
    statusCode: HTTPStatusCode,
    headers: HTTPHeaders,
    body: HTTPBody
  ) {
    self.url = url
    self.statusCode = statusCode
    self.headers = headers
    self.body = body
  }
}

public extension HTTPResponse {
  /// Initialize from Foundation URLResponse and raw Data.
  /// Returns nil if can't build proper HTTP response from provided parameters..
  /// - parameter response: URLResponse used as base for building this response.
  /// - parameter body: Body data associated with the response.
  init?(
    from response: URLResponse,
    body: Data? = nil
  ) {
    guard let httpResponse = response as? HTTPURLResponse,
          let url = httpResponse.url,
          let headers = httpResponse.allHeaderFields as? Dictionary<String, String>
    else { return nil }
    self.init(
      url: url,
      statusCode: HTTPStatusCode(rawValue: httpResponse.statusCode),
      headers: HTTPHeaders(rawDictionary: headers),
      body: HTTPBody(rawValue: body ?? Data())
    )
  }
}

extension HTTPResponse: CustomStringConvertible {
  
  public var description: String {
    """
    HTTP/1.1 \(statusCode.rawValue)\r
    \(headers.description)\r
    \(String(data: body.rawValue, encoding: .utf8) ?? "")
    """
  }
}
