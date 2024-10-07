import XCTest
@testable import SvenskBokforingAI

class TransactionTests: XCTestCase {
    func testVATCalculation() {
        let transaction = Transaction(date: "2023-10-06", description: "Test", amount: 100.0, vatRate: .standard)
        XCTAssertEqual(transaction.vatAmount, 20.0, accuracy: 0.01)
    }
}