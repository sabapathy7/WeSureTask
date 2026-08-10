////
//  WeSureTaskUITests.swift
//  WeSureTask
//
//  Created on 07.08.26.
//


import XCTest

final class WeSureTaskUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }

    @MainActor
    private func waitForPayrollsScreen(_ app: XCUIApplication) {
        let title = app.navigationBars["Payrolls"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
    }

    @MainActor
    private func openNewPayroll(_ app: XCUIApplication) {
        waitForPayrollsScreen(app)
        // systemImage "plus" often exposes accessibility as "New Payroll"
        let newButton = app.buttons["New Payroll"]
        XCTAssertTrue(newButton.waitForExistence(timeout: 2))
        newButton.tap()
        XCTAssertTrue(app.navigationBars["New Payroll"].waitForExistence(timeout: 3))
    }

    @MainActor
    private func fillFirstEmployee(_ app: XCUIApplication, name: String, wages: String, exempt: Bool = false) {
        let nameField = app.textFields["Employee Name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText(name)
        let wagesField = app.textFields["Wages"]
        wagesField.tap()
        wagesField.typeText(wages)
        if exempt {
            app.switches["Exempt from taxes"].tap()
        }
    }

    @MainActor
    func testEmptyState_onFreshLaunch() {
        let app = launchApp()
        waitForPayrollsScreen(app)

        XCTAssertTrue(
            app.staticTexts["No payrolls yet"].waitForExistence(timeout: 5)
        )
    }

    @MainActor
    func testCancelCreatePayroll_dismissesSheet() {
        let app = launchApp()
        openNewPayroll(app)
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Payrolls"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.navigationBars["New Payroll"].exists)
    }

    @MainActor
    func testCreatePayroll_appearsInList() {
        let app = launchApp()
        openNewPayroll(app)
        fillFirstEmployee(app, name: "Ada Lovelace", wages: "2500")
        app.buttons["Save"].tap()
        // Back on list
        XCTAssertTrue(app.navigationBars["Payrolls"].waitForExistence(timeout: 5))
        // Row shows employee count (inflected)
        XCTAssertTrue(app.staticTexts["1 employee"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSaveDisabled_untilEmployeeIsValid() {
        let app = launchApp()
        openNewPayroll(app)
        let save = app.buttons["Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 2))
        XCTAssertFalse(save.isEnabled)
        fillFirstEmployee(app, name: "Ada", wages: "1000")
        XCTAssertTrue(save.isEnabled)
    }
}
