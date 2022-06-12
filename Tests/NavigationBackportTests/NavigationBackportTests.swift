@testable import NavigationBackport
import XCTest

final class NavigationBackportTests: XCTestCase {
  func testPushOneAtATime() {
    let start = [1]
    let end = [-1, -2, -3, -4]

    let steps = NavigationBackport.calculateSteps(from: start, to: end, canPushMultiple: false)

    let expectedSteps = [
      [-1],
      [-1, -2],
      [-1, -2, -3],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }

  func testPushMultiple() {
    let start = [1]
    let end = [-1, -2, -3, -4]

    let steps = NavigationBackport.calculateSteps(from: start, to: end, canPushMultiple: true)

    let expectedSteps = [
      [-1],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
}
