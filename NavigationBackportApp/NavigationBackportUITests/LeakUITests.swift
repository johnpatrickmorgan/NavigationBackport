import XCTest

final class LeakUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  // MARK: Without NavigationStack

  // Note: NavigationStack itself does not immediately free up elements that are removed from its path,
  // so we only test when used without NavigationStack.
  func testLeakWithoutNavigationStack() {
    let app = XCUIApplication()

    app.launch()

    XCTAssertTrue(app.tabBars.buttons["LeakTest"].waitForExistence(timeout: 3))
    app.tabBars.buttons["LeakTest"].tap()

    XCTAssertTrue(app.buttons["Main"].exists)

    for _ in 0 ..< 3 {
      app.buttons["Main"].tap()
      XCTAssertTrue(app.navigationBars["Main"].waitForExistence(timeout: navigationTimeout))
      XCTAssertTrue(app.staticTexts["Count: 1"].exists)
      app.navigationBars.buttons.element(boundBy: 0).tap()
      XCTAssertTrue(app.buttons["Main"].waitForExistence(timeout: navigationTimeout))
    }
  }
}
