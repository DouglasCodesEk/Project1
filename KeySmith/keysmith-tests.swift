import XCTest
@testable import KeySmith

class KeySmithTests: XCTestCase {
    var macroEngine: MacroEngine!
    var variableManager: VariableManager!

    override func setUpWithError() throws {
        macroEngine = MacroEngine()
        variableManager = VariableManager()
    }

    func testCreateMacro() {
        let macro = Macro(name: "Test Macro")
        macroEngine.macroGroups.append(MacroGroup(name: "Test Group", macros: [macro]))
        XCTAssertEqual(macroEngine.macroGroups.first?.macros.count, 1)
    }

    func testVariableManager() {
        variableManager.variables["testVar"] = "testValue"
        XCTAssertEqual(variableManager.variables["testVar"], "testValue")
    }

    // Add more tests for other components
}

// UI Tests
class KeySmithUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testMacroCreation() {
        // Simulate creating a new macro through the UI
        app.buttons["New Macro"].tap()
        app.textFields["Macro Name"].typeText("UI Test Macro")
        // Add more UI interaction as needed
    }
}
