//
//  ChatScriptTests.swift
//  ChatScriptTests
//
//  Created by Admin on 2024-10-06.
//

import XCTest
@testable import ChatScript

final class ChatScriptTests: XCTestCase {

    func testAIServiceGenerateScriptSuccess() async throws {
        // Mocking AIService or using a test API key is necessary
        // For illustration, this test assumes a valid API key is set in the Keychain
        let aiService = AIService(provider: .openAI)
        let expectation = expectation(description: "Generate AppleScript")
        
        aiService.generateScript(from: "Create a Finder window") { result in
            switch result {
            case .success(let script):
                XCTAssertFalse(script.isEmpty, "Script should not be empty")
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testAIServiceGenerateScriptMissingAPIKey() async throws {
        // Ensure the API key is missing
        KeychainHelper.deleteAPIKey(for: .openAI)
        
        let aiService = AIService(provider: .openAI)
        let expectation = expectation(description: "Generate AppleScript with missing API key")
        
        aiService.generateScript(from: "Create a Finder window") { result in
            switch result {
            case .success(_):
                XCTFail("Expected failure due to missing API key")
            case .failure(let error):
                XCTAssertEqual(error as? AIServiceError, AIServiceError.missingAPIKey)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // Additional tests can be added here
}
