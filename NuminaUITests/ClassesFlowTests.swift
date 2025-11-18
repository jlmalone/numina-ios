import XCTest

final class ClassesFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()

        TestHelper.loginTestUser(app: app)
    }

    override func tearDownWithError() throws {
        TestHelper.logoutTestUser(app: app)
        app = nil
    }

    func testSearchAndViewClassDetails() throws {
        // Navigate to classes tab
        app.tabBars.buttons["Classes"].tap()

        // Search for classes
        let searchField = app.searchFields["Search classes"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("yoga")

        // Wait for results
        let firstClassCard = app.buttons.matching(identifier: "classCard").firstMatch
        XCTAssertTrue(firstClassCard.waitForExistence(timeout: 5))

        // Tap first result
        firstClassCard.tap()

        // Verify details screen
        let detailsView = app.otherElements["classDetailsView"]
        XCTAssertTrue(detailsView.waitForExistence(timeout: 3))
    }

    func testFilterClasses() throws {
        app.tabBars.buttons["Classes"].tap()

        // Open filters
        app.buttons["Filters"].tap()

        // Select a category
        app.buttons["Yoga"].tap()

        // Apply filters
        app.buttons["Apply Filters"].tap()

        // Verify filtered results
        XCTAssertTrue(TestHelper.waitForElement(app.staticTexts["Yoga Classes"]))
    }

    func testBookmarkClass() throws {
        app.tabBars.buttons["Classes"].tap()

        let firstClassCard = app.buttons.matching(identifier: "classCard").firstMatch
        XCTAssertTrue(firstClassCard.waitForExistence(timeout: 5))

        // Tap bookmark button
        let bookmarkButton = app.buttons.matching(identifier: "bookmarkButton").firstMatch
        bookmarkButton.tap()

        // Verify feedback
        XCTAssertTrue(TestHelper.waitForElement(app.staticTexts["Bookmarked"]))
    }
}
