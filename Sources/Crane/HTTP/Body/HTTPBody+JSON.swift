import class Foundation.JSONEncoder

public extension HTTPBody {
  /// Makes json body from provided content if able.
  /// - parameter content: Content to use for json conversion. Has to be `Encodable`.
  /// - parameter encoder: Encoder used to provide json conversion.
  /// - returns: HTTBody based on provided content converted to json.
  static func json<Content>(
    from content: Content,
    using encoder: JSONEncoder = JSONEncoder()
  ) throws -> HTTPBody
  where Content: Encodable {
    try HTTPBody(rawValue: encoder.encode(content))
  }
}
