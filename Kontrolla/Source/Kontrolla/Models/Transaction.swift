import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    var date: Date
    var description: String
    var amount: Decimal
    var category: String?
    var vatRate: VATRate
    var vatAmount: Decimal {
        return amount * vatRate.rawValue / (Decimal(1) + vatRate.rawValue)
    }
    
    init(id: UUID = UUID(), date: Date, description: String, amount: Decimal, category: String? = nil, vatRate: VATRate = .standard) {
        self.id = id
        self.date = date
        self.description = description
        self.amount = amount
        self.category = category
        self.vatRate = vatRate
    }
}

enum VATRate: Double {
    case standard = 0.25
    case reduced = 0.12
    case low = 0.06
    case zero = 0.0
}