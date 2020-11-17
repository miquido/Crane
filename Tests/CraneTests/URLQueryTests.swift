import XCTest
import Crane

final class URLQueryTests: XCTestCase {
  
  func test_empty_isEmpty() {
    let query: URLQuery = .empty
    
    XCTAssert(query.isEmpty)
  }
  
  func test_whenInitializingWithRawDictionary_thenRawDictionaryIsEqual() {
    let rawDictionary = ["string":"answer", "int": "42"]
    let query: URLQuery = .init(rawDictionary: rawDictionary)
    
    XCTAssert(!query.isEmpty)
    XCTAssertEqual(query.rawDictionary, rawDictionary)
  }
  
  func test_whenInitializingWithDictionaryLiteral_thenContainsAllLiteralFields() {
    let query: URLQuery = ["string": "answer", "int": 42]
    
    XCTAssert(!query.isEmpty)
    XCTAssertEqual(query["string"], "answer")
    XCTAssertEqual(query["int"], 42)
  }
  
  func test_whenMerging_thenContainsAllMergedFields() {
    let query: URLQuery = ["string": "answer"]
    let mergedQuery: URLQuery = query.merging(with: ["int": 42])
    
    XCTAssert(!mergedQuery.isEmpty)
    XCTAssertEqual(mergedQuery["string"], "answer")
    XCTAssertEqual(mergedQuery["int"], 42)
  }
  
  func test_whenMergingConflicting_withOverride_thenContainsAllMergedFields() {
    let query: URLQuery = ["string": "answer", "int": 0]
    let mergedQuery: URLQuery = query.merging(with: ["int": 42], override: true)
    
    XCTAssert(!mergedQuery.isEmpty)
    XCTAssertEqual(mergedQuery["string"], "answer")
    XCTAssertEqual(mergedQuery["int"], 42)
  }
  
  func test_whenMergingConflicting_withoutOverride_thenContainsAllMergedFields() {
    let query: URLQuery = ["string": "answer", "int": 42]
    let mergedQuery: URLQuery = query.merging(with: ["int": 0], override: false)
    
    XCTAssert(!mergedQuery.isEmpty)
    XCTAssertEqual(mergedQuery["string"], "answer")
    XCTAssertEqual(mergedQuery["int"], 42)
  }
  
  func test_whenPercentEncodingIsApplied_thenValuesAreNotChanged() {
    let rawDictionary = ["str ing":"a n=s?we%20r"]
    let query: URLQuery = .init(rawDictionary: rawDictionary)
    
    XCTAssertEqual(query.rawDictionary, rawDictionary)
  }
  
  func test_whenPercentEncodingIsApplied_thenQueryStringIsEncoded() {
    let query: URLQuery = .init(rawDictionary: ["str ing":"a n=s?we%20r"])
    
    XCTAssertEqual(query.percentEncodedString, "str%20ing=a%20n%3Ds%3Fwe%2520r")
  }
}
