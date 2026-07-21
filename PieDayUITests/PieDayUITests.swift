import XCTest

final class PieDayUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testEmptyStateCanAddTransaction() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["emptyTransactions"].waitForExistence(timeout: 3))
        app.buttons["addTransaction"].tap()
        let foodButton = app.buttons["支出 · 餐飲"]
        XCTAssertTrue(foodButton.waitForExistence(timeout: 2))
        foodButton.tap()

        let amountField = app.alerts["餐飲"].textFields["金額"]
        XCTAssertTrue(amountField.waitForExistence(timeout: 2))
        amountField.tap()
        amountField.typeText("120")
        app.alerts["餐飲"].buttons["儲存"].tap()

        let row = app.cells.matching(identifier: "transactionRow").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 2))
        XCTAssertTrue(row.label.contains("餐飲"))
        XCTAssertTrue(row.label.contains("120"))
    }

    func testDemoDashboardExposesAccessibleSummaryAndMonthNavigation() {
        let app = launchApp(demoData: true)
        app.tabBars.buttons["總覽"].tap()

        XCTAssertTrue(app.otherElements["metric收入"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.otherElements["metric收入"].value as? String == "")
        XCTAssertTrue(app.otherElements["metric支出"].exists)
        XCTAssertTrue(app.otherElements["metric可用"].exists)
        XCTAssertTrue(app.progressIndicators["整體預算使用進度"].exists)

        app.buttons["previousMonth"].tap()
        XCTAssertTrue(app.buttons["currentMonth"].exists)
        XCTAssertTrue(app.buttons["nextMonth"].isEnabled)
    }

    func testAccessibilityTextSizeKeepsCoreDashboardReachable() {
        let app = XCUIApplication()
        app.launchArguments = [
            "-ui-testing", "-ui-testing-demo-data",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
        ]
        app.launch()
        app.tabBars.buttons["總覽"].tap()

        XCTAssertTrue(app.otherElements["metric收入"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["metric支出"].exists)
        XCTAssertTrue(app.otherElements["metric可用"].exists)
        XCTAssertTrue(app.buttons["editBudgets"].exists)

        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        XCTAssertTrue(app.staticTexts["本月洞察"].waitForExistence(timeout: 2))
    }

    private func launchApp(demoData: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"] + (demoData ? ["-ui-testing-demo-data"] : [])
        app.launch()
        return app
    }
}
