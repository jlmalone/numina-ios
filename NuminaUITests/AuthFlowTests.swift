import XCTest

final class AuthFlowTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testLoginFlow() throws {
        // Tap login button
        let loginButton = app.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        // Enter credentials
        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 2))
        emailField.tap()
        emailField.typeText("test@example.com")

        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("test123")

        // Submit
        app.buttons["Sign In"].tap()

        // Verify navigation to home
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertTrue(tabBar.buttons["Home"].exists)
    }

    func testRegistrationFlow() throws {
        let registerButton = app.buttons["Register"]
        XCTAssertTrue(registerButton.waitForExistence(timeout: 5))
        registerButton.tap()

        // Fill registration form
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Test User")

        let emailField = app.textFields["emailField"]
        emailField.tap()
        emailField.typeText("newuser@example.com")

        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password123")

        // Submit
        app.buttons["Create Account"].tap()

        // Verify success
        let welcomeText = app.staticTexts["Welcome"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))
    }

    func testInvalidCredentials() throws {
        let loginButton = app.buttons["Login"]
        loginButton.tap()

        app.textFields["emailField"].tap()
        app.textFields["emailField"].typeText("wrong@example.com")

        app.secureTextFields["passwordField"].tap()
        app.secureTextFields["passwordField"].typeText("wrongpass")

        app.buttons["Sign In"].tap()

        // Verify error message
        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 3))
    }
}
