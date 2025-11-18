import XCTest

final class GroupsFlowTests: XCTestCase {
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

    func testCreateGroupFlow() throws {
        app.tabBars.buttons["Groups"].tap()

        // Tap create group button
        app.buttons["createGroupButton"].tap()

        // Fill form
        let nameField = app.textFields["groupNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Test Yoga Group")

        let descriptionField = app.textViews["groupDescriptionField"]
        descriptionField.tap()
        descriptionField.typeText("A group for yoga enthusiasts")

        // Select category
        app.buttons["Yoga"].tap()

        // Submit
        app.buttons["Create Group"].tap()

        // Verify navigation to group details
        let groupTitle = app.staticTexts["Test Yoga Group"]
        XCTAssertTrue(groupTitle.waitForExistence(timeout: 5))
    }

    func testJoinGroupFlow() throws {
        app.tabBars.buttons["Groups"].tap()

        // Tap on first group
        let firstGroup = app.buttons.matching(identifier: "groupCard").firstMatch
        XCTAssertTrue(firstGroup.waitForExistence(timeout: 5))
        firstGroup.tap()

        // Join group
        let joinButton = app.buttons["Join Group"]
        if joinButton.exists {
            joinButton.tap()

            // Verify membership
            XCTAssertTrue(TestHelper.waitForElement(app.buttons["Leave Group"]))
        }
    }

    func testCreateActivityFlow() throws {
        app.tabBars.buttons["Groups"].tap()

        let firstGroup = app.buttons.matching(identifier: "groupCard").firstMatch
        firstGroup.tap()

        // Create activity
        app.buttons["Create Activity"].tap()

        let titleField = app.textFields["activityTitleField"]
        titleField.tap()
        titleField.typeText("Morning Yoga Session")

        let descriptionField = app.textViews["activityDescriptionField"]
        descriptionField.tap()
        descriptionField.typeText("Join us for a relaxing morning yoga session")

        // Select date
        app.buttons["Select Date"].tap()
        // Date picker interaction...

        app.buttons["Create Activity"].tap()

        // Verify activity created
        XCTAssertTrue(TestHelper.waitForElement(app.staticTexts["Morning Yoga Session"]))
    }
}
