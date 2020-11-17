import struct Foundation.Data

extension Data: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: UInt8...) {
    self.init(elements)
  }  
}
