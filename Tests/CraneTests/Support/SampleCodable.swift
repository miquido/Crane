import struct Foundation.Data
import class Foundation.JSONEncoder

struct SampleCodable: Hashable, Codable {
  var string: String
  var optionalInt: Int?
}

extension SampleCodable {
  static var empty: Self { .init(string: "", optionalInt: nil) }
  static var answer: Self { .init(string: "answer", optionalInt: 42) }
}

extension SampleCodable {
  var jsonData: Data { try! JSONEncoder().encode(self) }
}
