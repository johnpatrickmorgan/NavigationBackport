@testable import NavigationBackport
import XCTest

final class NavigationBackportTests: XCTestCase {
  typealias RouterState = [Route<Int>]

  func testPushOneAtATime() {
    let start: RouterState = []
    let end: RouterState = [
      .push(-2),
      .push(-3),
      .push(-4),
    ]

    let steps = FlowPath.calculateSteps(from: start, to: end)

    let expectedSteps: [RouterState] = [
      [
      ],
      [
        .push(-2),
      ],
      [
        .push(-2),
        .push(-3),
      ],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }

  func testPopAllAtOnce() {
    let start: RouterState = [
      .push(2),
      .push(3),
      .push(4),
    ]
    let end: RouterState = [
    ]

    let steps = FlowPath.calculateSteps(from: start, to: end)

    let expectedSteps: [RouterState] = [
      [
        .push(2),
        .push(3),
        .push(4),
      ],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }

  func testPresentOneAtATime() {
    let start: RouterState = []
    let end: RouterState = [
      .sheet(-2),
      .cover(-3),
      .sheet(-4),
    ]

    let steps = FlowPath.calculateSteps(from: start, to: end)

    let expectedSteps: [RouterState] = [
      [
      ],
      [
        .sheet(-2),
      ],
      [
        .sheet(-2),
        .cover(-3),
      ],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }

  func testDismissOneAtATime() {
    let start: RouterState = [
      .sheet(2),
      .cover(3),
      .sheet(4),
    ]
    let end: RouterState = [
    ]

    let steps = FlowPath.calculateSteps(from: start, to: end)

    let expectedSteps: [RouterState] = [
      [
        .sheet(2),
        .cover(3),
        .sheet(4),
      ],
      [
        .sheet(2),
        .cover(3),
      ],
      [
        .sheet(2),
      ],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }

  func testPresentAndPushOneAtATime() {
    let start: RouterState = []
    let end: RouterState = [
      .push(-2),
      .push(-3),
      .sheet(-4),
      .sheet(-5),
    ]

    let steps = FlowPath.calculateSteps(from: start, to: end)

    let expectedSteps: [RouterState] = [
      [
      ],
      [
        .push(-2),
      ],
      [
        .push(-2),
        .push(-3),
      ],
      [
        .push(-2),
        .push(-3),
        .sheet(-4),
      ],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }

  func testBackToCommonAncestorFirst() {
    let start: RouterState = [
      .push(2),
      .push(3),
      .push(4),
    ]
    let end: RouterState = [
      .push(-2),
      .push(-3),
      .sheet(-4),
      .sheet(-5),
    ]

    let steps = FlowPath.calculateSteps(from: start, to: end)

    let expectedSteps: [RouterState] = [
      [
        .push(-2),
        .push(-3),
        .push(4),
      ],
      [
        .push(-2),
        .push(-3),
      ],
      [
        .push(-2),
        .push(-3),
        .sheet(-4),
      ],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }

  func testBackToCommonAncestorFirstWithoutPoppingWithinExtraPresentationLayers() {
    let start: RouterState = [
      .sheet(2),
      .push(3),
      .sheet(4),
      .push(5),
    ]
    let end: RouterState = [
      .push(-2),
    ]

    let steps = FlowPath.calculateSteps(from: start, to: end)
    
    print(steps)

    let expectedSteps: [RouterState] = [
      [
        .sheet(2),
        .push(3),
        .sheet(4),
        .push(5),
      ],
      [
        .sheet(2),
        .push(3),
      ],
      [
      ],
      end,
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
}
