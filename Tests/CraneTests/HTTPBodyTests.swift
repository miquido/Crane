import XCTest
import Crane

final class HTTPBodyTests: XCTestCase {
  
  func test_empty_isEmpty() {
    let body: HTTPBody = .empty
    
    XCTAssert(body.isEmpty)
  }
  
  func test_whenInitializingWithByte_thenLengthIsOne() {
    let body: HTTPBody = .init(rawValue: [0x2A])
    
    XCTAssert(!body.isEmpty)
    XCTAssert(body.rawValue == [0x2A])
  }
  
  func test_whenAppendingByte_thenContainsThatByte() {
    let body: HTTPBody = .empty

    let extendedBody = body.appending([0x2A])
    
    XCTAssert(!extendedBody.isEmpty)
    XCTAssert(extendedBody.rawValue == [0x2A])
  }
  
  func test_whenMakingJSON_thenContainsThatJSONBytes() {
    let body: HTTPBody = try! .json(from: SampleCodable.answer)
    
    XCTAssert(!body.isEmpty)
    XCTAssert(body.rawValue == SampleCodable.answer.jsonData)
  }
}
