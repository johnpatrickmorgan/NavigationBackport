@testable import NavigationBackport
import XCTest

final class NavigationBackportTests: XCTestCase {
  func testPushOneAtATime() {
    let start = [1]
    let end = [-1, -2, -3, -4]

    let steps = NavigationBackport.calculateSteps(from: start, to: end)

    let expectedSteps = [
      [-1],
      [-1, -2],
      [-1, -2, -3],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
  
  func testPopAllInOne() {
    let start = [1, 2, 3, 4]
    let end = [-1]

    let steps = NavigationBackport.calculateSteps(from: start, to: end)

    let expectedSteps = [end]
    XCTAssertEqual(steps, expectedSteps)
  }
}
