import XCTest

final class MessagingFlowTests: XCTestCase {
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

    func testSendMessageFlow() throws {
        app.tabBars.buttons["Messages"].tap()

        // Tap on first conversation
        let firstConversation = app.buttons.matching(identifier: "conversationItem").firstMatch
        XCTAssertTrue(firstConversation.waitForExistence(timeout: 5))
        firstConversation.tap()

        // Send message
        let messageField = app.textFields["messageInput"]
        XCTAssertTrue(messageField.waitForExistence(timeout: 2))
        messageField.tap()
        messageField.typeText("Test message")

        app.buttons["sendButton"].tap()

        // Verify message appears
        let sentMessage = app.staticTexts["Test message"]
        XCTAssertTrue(sentMessage.waitForExistence(timeout: 3))
    }

    func testStartNewConversationFlow() throws {
        app.tabBars.buttons["Messages"].tap()

        app.buttons["New Chat"].tap()

        // Search for user
        let searchField = app.searchFields["Search users"]
        searchField.tap()
        searchField.typeText("Test User")

        // Select user
        let userResult = app.buttons.matching(identifier: "userSearchResult").firstMatch
        XCTAssertTrue(userResult.waitForExistence(timeout: 3))
        userResult.tap()

        // Verify conversation started
        let messageField = app.textFields["messageInput"]
        XCTAssertTrue(messageField.waitForExistence(timeout: 2))
    }
}
