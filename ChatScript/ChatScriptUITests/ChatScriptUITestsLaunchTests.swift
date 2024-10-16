//
//  ChatScriptUITests.swift
//  ChatScriptUITests
//
//  Created by Admin on 2024-10-06.
//

import XCTest

final class ChatScriptUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Set the initial state required for tests before they run.
        // For example, interface orientation.
    }

    override func tearDownWithError() throws {
        // Put teardown code here.
    }

    @MainActor
    func testGenerateScriptButton() throws {
        let app = XCUIApplication()
        app.launch()
        
        let userInputTextEditor = app.textViews["userInputTextEditor"]
        XCTAssertTrue(userInputTextEditor.exists, "User Input TextEditor should exist")
        userInputTextEditor.click()
        userInputTextEditor.typeText("Create a Finder window")
        
        let generateButton = app.buttons["generateScriptButton"]
        XCTAssertTrue(generateButton.exists, "Generate Script button should exist")
        generateButton.click()
        
        // Verify that the loading indicator appears
        let progressView = app.activityIndicators.element
        XCTAssertTrue(progressView.exists, "Loading indicator should appear")
        
        // Wait for the script output to be populated (this is a simplification)
        let scriptOutputTextEditor = app.textViews["scriptOutputTextEditor"]
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: scriptOutputTextEditor, handler: nil)
        waitForExpectations(timeout: 20, handler: nil)
        
        XCTAssertFalse(scriptOutputTextEditor.value as? String == "", "Script Output should not be empty")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // Measure how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
