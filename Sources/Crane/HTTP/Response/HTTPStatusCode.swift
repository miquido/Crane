/// Status code of HTTP response.
public struct HTTPStatusCode: RawRepresentable {
  /// Raw int value of this status.
  public var rawValue: Int
  /// Initialize using raw value.
  /// - parameter rawValue: Raw int value of this status.
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

extension HTTPStatusCode: Hashable {}

extension HTTPStatusCode: Comparable {
  
  public static func < (
    lhs: HTTPStatusCode,
    rhs: HTTPStatusCode
  ) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

extension HTTPStatusCode: ExpressibleByIntegerLiteral {
  
  public init(integerLiteral value: Int) {
    self.init(rawValue: value)
  }
}

// TODO: we could add description for common codes
public extension HTTPStatusCode {
  
  // MARK: - 100..<200
  static let `continue`: HTTPStatusCode = 100
  static let switchingProtocols: HTTPStatusCode = 101
  static let processing: HTTPStatusCode = 102
  
  // MARK: - 200..<300
  static let ok: HTTPStatusCode = 200
  static let created: HTTPStatusCode = 201
  static let accepted: HTTPStatusCode = 202
  static let nonAuthoritativeInformation: HTTPStatusCode = 203
  static let noContent: HTTPStatusCode = 204
  static let resetContent: HTTPStatusCode = 205
  static let partialContent: HTTPStatusCode = 206
  static let multiStatus: HTTPStatusCode = 207
  static let alreadyReported: HTTPStatusCode = 208
  
  // MARK: - 300..<400
  static let multipleChoices: HTTPStatusCode = 300
  static let movedPermanently: HTTPStatusCode = 301
  static let found: HTTPStatusCode = 302
  static let seeOther: HTTPStatusCode = 303
  static let notModified: HTTPStatusCode = 304
  static let useProxy: HTTPStatusCode = 305
  static let temporaryRedirect: HTTPStatusCode = 307
  static let permanentRedirect: HTTPStatusCode = 308
  
  // MARK: - 400..<500
  static let badRequest: HTTPStatusCode = 400
  static let unauthorized: HTTPStatusCode = 401
  static let paymentRequired: HTTPStatusCode = 402
  static let forbidden: HTTPStatusCode = 403
  static let notFound: HTTPStatusCode = 404
  static let methodNotAllowed: HTTPStatusCode = 405
  static let notAcceptable: HTTPStatusCode = 406
  static let proxyAuthenticationRequired: HTTPStatusCode = 407
  static let requestTimeout: HTTPStatusCode = 408
  static let conflict: HTTPStatusCode = 409
  static let gone: HTTPStatusCode = 410
  static let lengthRequired: HTTPStatusCode = 411
  static let preconditionFailed: HTTPStatusCode = 412
  static let payloadTooLarge: HTTPStatusCode = 413
  static let uriTooLong: HTTPStatusCode = 414
  static let unsupportedMediaType: HTTPStatusCode = 415
  static let rangeNotSatisfiable: HTTPStatusCode = 416
  static let expectationFailed: HTTPStatusCode = 417
  static let imATeapot: HTTPStatusCode = 418
  static let misdirectedRequest: HTTPStatusCode = 421
  static let unprocessableEntity: HTTPStatusCode = 422
  static let locked: HTTPStatusCode = 423
  static let failedDependency: HTTPStatusCode = 424
  static let upgradeRequired: HTTPStatusCode = 426
  static let preconditionRequired: HTTPStatusCode = 428
  static let tooManyRequests: HTTPStatusCode = 429
  static let requestHeaderFieldsTooLarge: HTTPStatusCode = 431
  static let unavailableForLegalReasons: HTTPStatusCode = 451
  
  // MARK: - 500..<600
  static let internalServerError: HTTPStatusCode = 500
  static let notImplemented: HTTPStatusCode = 501
  static let badGateway: HTTPStatusCode = 502
  static let serviceUnavailable: HTTPStatusCode = 503
  static let gatewayTimeout: HTTPStatusCode = 504
  static let httpVersionNotSupported: HTTPStatusCode = 505
  static let variantAlsoNegotiates: HTTPStatusCode = 506
  static let insufficientStorage: HTTPStatusCode = 507
  static let loopDetected: HTTPStatusCode = 508
  static let notExtended: HTTPStatusCode = 510
  static let networkAuthenticationRequired: HTTPStatusCode = 511
}
