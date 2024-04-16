import XCTest

final class LocalDestinationUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  // MARK: Without NavigationStack

  func testLocalDestinationViaPathWithoutNavigationStack() {
    launchAndRunLocalDestinationTests(tabTitle: "NBNavigationPath", useNavigationStack: false, app: XCUIApplication())
  }

  func testLocalDestinationViaArrayWithoutNavigationStack() {
    launchAndRunLocalDestinationTests(tabTitle: "ArrayBinding", useNavigationStack: false, app: XCUIApplication())
  }

  func testLocalDestinationViaNoneWithoutNavigationStack() {
    launchAndRunLocalDestinationTests(tabTitle: "NoBinding", useNavigationStack: false, app: XCUIApplication())
  }

  // MARK: With NavigationStack

  func testLocalDestinationViaPathWithNavigationStack() {
    launchAndRunLocalDestinationTests(tabTitle: "NBNavigationPath", useNavigationStack: true, app: XCUIApplication())
  }

  func testLocalDestinationViaArrayWithNavigationStack() {
    launchAndRunLocalDestinationTests(tabTitle: "ArrayBinding", useNavigationStack: true, app: XCUIApplication())
  }

  func testLocalDestinationViaNoneWithNavigationStack() {
    launchAndRunLocalDestinationTests(tabTitle: "NoBinding", useNavigationStack: true, app: XCUIApplication())
  }

  func launchAndRunLocalDestinationTests(tabTitle: String, useNavigationStack: Bool, app: XCUIApplication) {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *) {
      // Can test with and without NavigationStack
    } else if useNavigationStack {
      // Can only test without NavigationStack
      return
    }

    if useNavigationStack {
      app.launchArguments.append("USE_NAVIGATIONSTACK")
    }
    app.launch()

    XCTAssertTrue(app.tabBars.buttons[tabTitle].waitForExistence(timeout: 3))
    app.tabBars.buttons[tabTitle].tap()

    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Push traffic lights"].tap()

    XCTAssertTrue(app.staticTexts["red"].waitForExistence(timeout: 1))
    app.staticTexts["red"].tap()
    
    XCTAssertTrue(app.staticTexts["amber"].waitForExistence(timeout: 1))
    app.staticTexts["amber"].tap()
    
    XCTAssertTrue(app.staticTexts["green"].waitForExistence(timeout: 1))
    app.staticTexts["green"].tap()

    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Push local destination"].tap()
    XCTAssertTrue(app.staticTexts["Local destination"].waitForExistence(timeout: navigationTimeout))

    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.buttons["Push local destination"].isEnabled)

    app.buttons["Push local destination"].tap()
  }
}
