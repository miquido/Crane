import XCTest
import Crane

final class URLPathTests: XCTestCase {
  
  func test_emptyStringLiteral_isEmpty() {
    let path: URLPath = ""
    
    XCTAssert(path.isEmpty)
  }
  
  func test_stringLiteralPath_isTranslatedToSamePath() {
    let path: URLPath = "/test/answer/42/path"
    
    XCTAssertEqual(path.percentEncodedString, "/test/answer/42/path")
  }
  
  func test_emptyArrayLiteral_isEmpty() {
    let path: URLPath = []
    
    XCTAssert(path.isEmpty)
  }
  
  func test_stringLiteralPathRequiringEncoding_isTranslatedToEncodedPath() {
    let path: URLPath = "/test/answer/4 2/path"
    
    XCTAssertEqual(path.percentEncodedString, "/test/answer/4%202/path")
  }
  
  func test_arrayLiteralPath_isTranslatedToCorrespondingPath() {
    let path: URLPath = ["test", "answer", 42, "path"]
    
    XCTAssertEqual(path.percentEncodedString, "/test/answer/42/path")
  }
  
  func test_arrayLiteralPathRequiringEncoding_isTranslatedToEncodedPath() {
    let path: URLPath = ["te/st", "answer", 42, "pa th"]
    
    XCTAssertEqual(path.percentEncodedString, "/te/st/answer/42/pa%20th")
  }
  
  func test_whenPrependingPath_thenPathHasThatPrefix() {
    let path: URLPath = "/test/answer/42/path"
    
    let updatedPath = path.prepending("prefix")
    
    XCTAssertEqual(updatedPath.percentEncodedString, "/prefix/test/answer/42/path")
  }
  
  func test_whenAppendingPath_thenPathHasThatSuffix() {
    let path: URLPath = "/test/answer/42/path"
    
    let updatedPath = path.appending("suffix")
    
    XCTAssertEqual(updatedPath.percentEncodedString, "/test/answer/42/path/suffix")
  }
}
