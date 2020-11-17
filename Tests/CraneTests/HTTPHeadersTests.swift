import XCTest
import Crane

final class HTTPHeadersTests: XCTestCase {
  
  func test_empty_isEmpty() {
    let headers: HTTPHeaders = .empty
    
    XCTAssert(headers.isEmpty)
  }
  
  func test_whenInitializingWithRawDictionary_thenRawDictionaryIsEqual() {
    let rawDictionary = ["string":"answer", "int": "42"]
    let headers: HTTPHeaders = .init(rawDictionary: rawDictionary)
    
    XCTAssert(!headers.isEmpty)
    XCTAssert(headers.rawDictionary == rawDictionary)
  }
  
  func test_whenInitializingWithDictionaryLiteral_thenContainsAllLiteralFields() {
    let headers: HTTPHeaders = ["string": "answer", "int": 42]
    
    XCTAssert(!headers.isEmpty)
    XCTAssert(headers["string"] == "answer")
    XCTAssert(headers["int"] == 42)
  }
  
  func test_whenMerging_thenContainsAllMergedFields() {
    let headers: HTTPHeaders = ["string": "answer"]
    let mergedHeaders: HTTPHeaders = headers.merging(with: ["int": 42])
    
    XCTAssert(!mergedHeaders.isEmpty)
    XCTAssert(mergedHeaders["string"] == "answer")
    XCTAssert(mergedHeaders["int"] == 42)
  }
  
  func test_whenMergingConflicting_withOverride_thenContainsAllMergedFields() {
    let headers: HTTPHeaders = ["string": "answer", "int": 0]
    let mergedHeaders: HTTPHeaders = headers.merging(with: ["int": 42], override: true)
    
    XCTAssert(!mergedHeaders.isEmpty)
    XCTAssert(mergedHeaders["string"] == "answer")
    XCTAssert(mergedHeaders["int"] == 42)
  }
  
  func test_whenMergingConflicting_withoutOverride_thenContainsAllMergedFields() {
    let headers: HTTPHeaders = ["string": "answer", "int": 42]
    let mergedHeaders: HTTPHeaders = headers.merging(with: ["int": 0], override: false)
    
    XCTAssert(!mergedHeaders.isEmpty)
    XCTAssert(mergedHeaders["string"] == "answer")
    XCTAssert(mergedHeaders["int"] == 42)
  }
}
