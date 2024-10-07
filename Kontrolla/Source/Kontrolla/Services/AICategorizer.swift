import Foundation
import CoreML

class AICategorizer {
    static let shared = AICategorizer()
    private var model: TransactionCategorizationModel?

    init() {
        loadModel()
    }

    func loadModel() {
        do {
            let config = MLModelConfiguration()
            model = try TransactionCategorizationModel(configuration: config)
        } catch {
            print("Error loading model: \(error.localizedDescription)")
        }
    }

    func categorize(transaction: Transaction) {
        guard let model = model else { return }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let prediction = try model.prediction(
                    description: transaction.description,
                    amount: transaction.amount
                )
                DispatchQueue.main.async {
                    var updatedTransaction = transaction
                    updatedTransaction.category = prediction.category
                    updatedTransaction.vatRate = self.determineVATRate(for: prediction.category)
                    // Update the transaction in the store
                    if let index = TransactionStore.shared.transactions.firstIndex(where: { $0.id == transaction.id }) {
                        TransactionStore.shared.transactions[index] = updatedTransaction
                    }
                }
            } catch {
                print("Error during prediction: \(error.localizedDescription)")
                // Prompt user for manual categorization
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .aiCategorizationFailed, object: transaction)
                }
            }
        }
    }

    func determineVATRate(for category: String) -> VATRate {
        switch category {
        case "Food":
            return .reduced
        case "Books":
            return .low
        default:
            return .standard
        }
    }
}

extension Notification.Name {
    static let aiCategorizationFailed = Notification.Name("aiCategorizationFailed")
}