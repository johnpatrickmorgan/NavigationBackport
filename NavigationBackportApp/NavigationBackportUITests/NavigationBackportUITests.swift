import XCTest

final class NavigationBackportUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testNavigationViaPathWithNBNavigationStack() throws {
    let app = XCUIApplication()
    app.launch()
    try runNavigationTests(tabTitle: "NBNavigationPath", app: app)
  }

  func testNavigationViaArrayWithNBNavigationStack() throws {
    let app = XCUIApplication()
    app.launch()
    try runNavigationTests(tabTitle: "ArrayBinding", app: app)
  }

  func testNavigationViaNoneWithNBNavigationStack() throws {
    let app = XCUIApplication()
    app.launch()
    try runNavigationTests(tabTitle: "NoBinding", app: app)
  }

  func testNavigationViaPathWithNavigationStack() throws {
    let app = XCUIApplication()
    app.launchArguments = ["USE_NAVIGATIONSTACK"]
    app.launch()
    try runNavigationTests(tabTitle: "NBNavigationPath", app: app)
  }

  func testNavigationViaArrayWithNavigationStack() throws {
    let app = XCUIApplication()
    app.launchArguments = ["USE_NAVIGATIONSTACK"]
    app.launch()
    try runNavigationTests(tabTitle: "ArrayBinding", app: app)
  }

  func testNavigationViaNoneWithNavigationStack() throws {
    let app = XCUIApplication()
    app.launchArguments = ["USE_NAVIGATIONSTACK"]
    app.launch()
    try runNavigationTests(tabTitle: "NoBinding", app: app)
  }

  func runNavigationTests(tabTitle: String, app: XCUIApplication) throws {
    let navigationTimeout = 0.8

    XCTAssertTrue(app.tabBars.buttons[tabTitle].waitForExistence(timeout: 3))
    app.tabBars.buttons[tabTitle].tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 2))

    app.buttons["Pick a number"].tap()
    XCTAssertTrue(app.navigationBars["List"].waitForExistence(timeout: navigationTimeout))

    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    app.buttons["99 Red balloons"].tap()
    XCTAssertTrue(app.navigationBars["Visualise 99"].waitForExistence(timeout: 2 * navigationTimeout))

    app.navigationBars.buttons.element(boundBy: 0).tap()
    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Pick a number"].tap()
    XCTAssertTrue(app.navigationBars["List"].waitForExistence(timeout: navigationTimeout))

    app.buttons["1"].tap()
    XCTAssertTrue(app.navigationBars["1"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Show next number"].tap()
    XCTAssertTrue(app.navigationBars["2"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Show next number"].tap()
    XCTAssertTrue(app.navigationBars["3"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Show next number"].tap()
    XCTAssertTrue(app.navigationBars["4"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Go back to root"].tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    if #available(iOS 15.0, *) {
      // This test fails on iOS 14, despite working in real use.
      app.buttons["Push local destination"].tap()
      XCTAssertTrue(app.staticTexts["Local destination"].waitForExistence(timeout: navigationTimeout * 2))

      app.navigationBars.buttons.element(boundBy: 0).tap()
      XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))
      XCTAssertTrue(app.buttons["Push local destination"].isEnabled)
    }

    if tabTitle != "ArrayBinding" {
      app.buttons["Show Class Destination"].tap()
      XCTAssertTrue(app.staticTexts["Sample data"].waitForExistence(timeout: navigationTimeout))

      app.navigationBars.buttons.element(boundBy: 0).tap()
      XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))
    }
  }
}
