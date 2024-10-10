import XCTest

final class InitialisationUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  // MARK: With NavigationStack

  func testInitialisationViaPathWithNavigationStack() {
    launchAndRunInitialisationTests(tabTitle: "NBNavigationPath", useNavigationStack: true, app: XCUIApplication())
  }

  func testInitialisationViaArrayWithNavigationStack() {
    launchAndRunInitialisationTests(tabTitle: "ArrayBinding", useNavigationStack: true, app: XCUIApplication())
  }

  // MARK: Without NavigationStack

  func testInitialisationViaPathWithoutNavigationStack() {
    launchAndRunInitialisationTests(tabTitle: "NBNavigationPath", useNavigationStack: false, app: XCUIApplication())
  }

  func testInitialisationViaArrayWithoutNavigationStack() {
    launchAndRunInitialisationTests(tabTitle: "ArrayBinding", useNavigationStack: false, app: XCUIApplication())
  }

  func launchAndRunInitialisationTests(tabTitle: String, useNavigationStack: Bool, app: XCUIApplication) {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *) {
      // Can test with and without NavigationStack
      if #available(iOS 18.0, *) {
        // Can only test with NavigationStack
        return
      }
    } else if useNavigationStack {
      // Can only test without NavigationStack
      return
    }

    app.launchArguments = ["NON_EMPTY_AT_LAUNCH"]
    if useNavigationStack {
      app.launchArguments.append("USE_NAVIGATIONSTACK")
    }
    app.launch()

    XCTAssertTrue(app.tabBars.buttons[tabTitle].waitForExistence(timeout: 3))
    app.tabBars.buttons[tabTitle].tap()

    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), useNavigationStack {
      XCTAssertTrue(app.navigationBars["4"].waitForExistence(timeout: navigationTimeout))
    } else {
      // When not using a NavigationStack, each screen is pushed one by one.
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
}
