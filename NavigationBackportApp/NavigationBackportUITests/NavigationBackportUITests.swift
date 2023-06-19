import XCTest

let navigationTimeout = 0.8

final class NavigationBackportUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testNavigationViaPathWithNBNavigationStack() {
    launchAndRunNavigationTests(tabTitle: "NBNavigationPath", useNavigationStack: false, app: XCUIApplication())
  }

  func testNavigationViaArrayWithNBNavigationStack() {
    launchAndRunNavigationTests(tabTitle: "ArrayBinding", useNavigationStack: false, app: XCUIApplication())
  }

  func testNavigationViaNoneWithNBNavigationStack() {
    launchAndRunNavigationTests(tabTitle: "NoBinding", useNavigationStack: false, app: XCUIApplication())
  }

  func testNavigationViaPathWithNavigationStack() {
    launchAndRunNavigationTests(tabTitle: "NBNavigationPath", useNavigationStack: true, app: XCUIApplication())
  }

  func testNavigationViaArrayWithNavigationStack() {
    launchAndRunNavigationTests(tabTitle: "ArrayBinding", useNavigationStack: true, app: XCUIApplication())
  }

  func testInitialisationViaArrayWithNavigationStack() {
    launchAndRunInitialisationTests(tabTitle: "ArrayBinding", useNavigationStack: true, app: XCUIApplication())
  }

  func testInitialisationViaPathWithNavigationStack() {
    launchAndRunInitialisationTests(tabTitle: "NBNavigationPath", useNavigationStack: true, app: XCUIApplication())
  }

  func launchAndRunInitialisationTests(tabTitle: String, useNavigationStack: Bool, app: XCUIApplication) {
    app.launchArguments = ["NON_EMPTY_AT_LAUNCH"]
    if useNavigationStack {
      app.launchArguments.append("USE_NAVIGATIONSTACK")
    }
    app.launch()

    XCTAssertTrue(app.tabBars.buttons[tabTitle].waitForExistence(timeout: 3))
    app.tabBars.buttons[tabTitle].tap()

    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 7.0, *, tvOS 16.0, *) {
      XCTAssertTrue(app.navigationBars["4"].waitForExistence(timeout: navigationTimeout))
    } else {
      XCTAssertTrue(app.navigationBars["4"].waitForExistence(timeout: navigationTimeout * 4))
    }

    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(app.navigationBars["3"].waitForExistence(timeout: navigationTimeout))

    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(app.navigationBars["2"].waitForExistence(timeout: navigationTimeout))

    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(app.navigationBars["1"].waitForExistence(timeout: navigationTimeout))

    app.navigationBars.buttons.element(boundBy: 0).tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))
  }

  func launchAndRunNavigationTests(tabTitle: String, useNavigationStack: Bool, app: XCUIApplication) {
    if useNavigationStack {
      app.launchArguments = ["USE_NAVIGATIONSTACK"]
    }
    app.launch()

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
