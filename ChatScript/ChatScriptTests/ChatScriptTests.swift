import XCTest
@testable import ChatScript

class ChatScriptTests: XCTestCase {
    
    var viewModel: AIServiceViewModel!
    
    override func setUpWithError() throws {
        viewModel = AIServiceViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testGenerateScript() {
        let expectation = XCTestExpectation(description: "Generate script")
        
        viewModel.userInput = "Create a script that says hello world"
        viewModel.generateScript()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertFalse(self.viewModel.scriptOutput.isEmpty)
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
    }
    
    func testExecuteScript() {
        let expectation = XCTestExpectation(description: "Execute script")
        
        viewModel.scriptOutput = "display dialog \"Hello, World!\""
        viewModel.executeScript()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertFalse(self.viewModel.executionResult.isEmpty)
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testErrorHandling() {
        let expectation = XCTestExpectation(description: "Handle error")
        
        viewModel.scriptOutput = "invalid script"
        viewModel.executeScript()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertFalse(self.viewModel.executionResult.isEmpty)
            XCTAssertTrue(self.viewModel.executionResult.contains("error"))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    // Add more tests for other scenarios and edge cases
}
