import XCTest

class SvenskBokforingAIUITests: XCTestCase {
    func testLoginView() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields["Password"].exists)
    }
}