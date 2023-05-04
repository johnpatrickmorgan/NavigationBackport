import XCTest

final class NavigationBackportUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  let tabTitles = ["NBNavigationPath", "ArrayBinding", "NoBinding"]
  let navigationTimeout = 0.8

  func testNavigationWithNBNavigationStack() throws {
    let app = XCUIApplication()
    app.launch()

    for tabTitle in tabTitles {
      try runNavigationTests(tabTitle: tabTitle, app: app)
    }
  }

  func testNavigationWithNavigationStack() throws {
    if #available(iOS 16.0, *) {
      let app = XCUIApplication()
      app.launchArguments = ["USE_NAVIGATIONSTACK"]
      app.launch()

      for tabTitle in tabTitles {
        try runNavigationTests(tabTitle: tabTitle, app: app)
      }
    }
  }

  func runNavigationTests(tabTitle: String, app: XCUIApplication) throws {
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
    XCTAssertTrue(app.switches.element(boundBy: 0).isOff)
    app.switches.element(boundBy: 0).tap()

    XCTAssertTrue(app.staticTexts["Local destination"].waitForExistence(timeout: navigationTimeout))
    app.navigationBars.buttons.element(boundBy: 0).tap()

    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.switches.element(boundBy: 0).isOff)

    if tabTitle != "ArrayBinding" {
      app.buttons["Show Class Destination"].tap()
      XCTAssertTrue(app.staticTexts["Sample data"].waitForExistence(timeout: navigationTimeout))
      app.navigationBars.buttons.element(boundBy: 0).tap()

      XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))
    }
  }
}

/// Utility extension for toggle switches.
extension XCUIElement {
  var isOn: Bool {
    return (value as? String) == "1"
  }

  var isOff: Bool { !isOn }
}