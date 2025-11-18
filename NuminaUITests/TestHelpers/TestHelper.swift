import XCTest

class TestHelper {
    static func loginTestUser(app: XCUIApplication) {
        // Navigate to login if not already logged in
        if app.buttons["Login"].exists {
            app.buttons["Login"].tap()

            let emailField = app.textFields["emailField"]
            emailField.tap()
            emailField.typeText("test@example.com")

            let passwordField = app.secureTextFields["passwordField"]
            passwordField.tap()
            passwordField.typeText("test123")

            app.buttons["Sign In"].tap()

            // Wait for home screen
            _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        }
    }

    static func logoutTestUser(app: XCUIApplication) {
        if app.tabBars.buttons["Profile"].exists {
            app.tabBars.buttons["Profile"].tap()
            app.buttons["Logout"].tap()
        }
    }

    static func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        return element.waitForExistence(timeout: timeout)
    }
}
