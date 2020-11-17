import XCTest
//import Foundation
import Crane

final class CancelationTokenTests: XCTestCase {
  
  func test_whenInitialized_statusIsNotCanceled() {
    let token: CancelationToken = .manual
    XCTAssertFalse(token.isCanceled)
  }
  
  func test_whenManualCanceled_statusIsCanceled() {
    let token: CancelationToken = .manual
    token.cancel()
    XCTAssertTrue(token.isCanceled)
  }
  
  func test_whenWithTimeoutCanceled_statusIsCanceled() {
    let token: CancelationToken = .withTimeout(3)
    token.cancel()
    XCTAssertTrue(token.isCanceled)
  }
  
  func test_whenWithDeadlineCanceled_statusIsCanceled() {
    let token: CancelationToken = .withDeadline(Date(timeIntervalSinceNow: 3))
    token.cancel()
    XCTAssertTrue(token.isCanceled)
  }
  
  func test_whenWithTimeoutTimesOut_statusIsCanceled() {
    let token: CancelationToken = .withTimeout(0.5)
    sleep(1)
    XCTAssertTrue(token.isCanceled)
  }
  
  func test_whenWithDeadlinePassDeadline_statusIsCanceled() {
    let token: CancelationToken = .withDeadline(Date(timeIntervalSinceNow: 0.5))
    sleep(1)
    XCTAssertTrue(token.isCanceled)
  }
  
  func test_whenWithClosureCanceled_statusIsCanceled() {
    let token: CancelationToken = .withClosure {}
    token.cancel()
    XCTAssertTrue(token.isCanceled)
  }
  
  func test_whenWithClosureCanceled_closureIsCalledOnce() {
    var calledCount = 0
    let token: CancelationToken = .withClosure { calledCount += 1}
    token.cancel()
    token.cancel()
    token.cancel()
    XCTAssertEqual(calledCount, 1)
  }
  
  func test_whenCombinedCanceled_allStatuesAreCanceled() {
    let inner_1: CancelationToken = .manual
    let inner_2: CancelationToken = .manual
    let token: CancelationToken = .combined(inner_1, inner_2)
    token.cancel()
    XCTAssertTrue(inner_1.isCanceled)
    XCTAssertTrue(inner_2.isCanceled)
    XCTAssertTrue(token.isCanceled)
  }
  
  func test_whenCombinedPartiallyCanceled_statusIsNotCanceled() {
    let inner_1: CancelationToken = .manual
    let inner_2: CancelationToken = .manual
    let token: CancelationToken = .combined(inner_1, inner_2)
    inner_1.cancel()
    XCTAssertTrue(inner_1.isCanceled)
    XCTAssertFalse(inner_2.isCanceled)
    XCTAssertFalse(token.isCanceled)
  }
  
  func test_whenNeverIsCanceled_statusIsNotCanceled() {
    let token: CancelationToken = .never
    token.cancel()
    XCTAssertFalse(token.isCanceled)
  }
}
