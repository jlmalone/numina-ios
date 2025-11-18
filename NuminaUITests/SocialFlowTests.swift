import XCTest

final class SocialFlowTests: XCTestCase {
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

    func testViewFeedAndLikeActivity() throws {
        app.tabBars.buttons["Feed"].tap()

        // Wait for feed to load
        let firstActivity = app.buttons.matching(identifier: "activityCard").firstMatch
        XCTAssertTrue(firstActivity.waitForExistence(timeout: 5))

        // Like activity
        let likeButton = app.buttons.matching(identifier: "likeButton").firstMatch
        likeButton.tap()

        // Verify like registered
        XCTAssertTrue(likeButton.isSelected)
    }

    func testFollowUserFlow() throws {
        app.tabBars.buttons["Feed"].tap()

        // Tap on user profile
        let userAvatar = app.buttons.matching(identifier: "userAvatar").firstMatch
        userAvatar.tap()

        // Follow user
        let followButton = app.buttons["Follow"]
        if followButton.exists {
            followButton.tap()

            // Verify following
            XCTAssertTrue(TestHelper.waitForElement(app.buttons["Following"]))
        }
    }
}
