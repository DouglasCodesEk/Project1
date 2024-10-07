import Foundation
import CoreData

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchTransactions()
    }
    
    func fetchTransactions() {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            let results = try context.fetch(request)
            self.transactions = results.map { Transaction(from: $0) }
        } catch {
            print("Error fetching transactions: \(error)")
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        let newTransaction = TransactionEntity(context: context)
        newTransaction.update(from: transaction)
        
        saveContext()
        fetchTransactions()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let existingTransaction = results.first {
                existingTransaction.update(from: transaction)
                saveContext()
                fetchTransactions()
            }
        } catch {
            print("Error updating transaction: \(error)")
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let existingTransaction = results.first {
                context.delete(existingTransaction)
                saveContext()
                fetchTransactions()
            }
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

extension Transaction {
    init(from entity: TransactionEntity) {
        self.id = entity.id ?? UUID()
        self.date = entity.date ?? Date()
        self.description = entity.transactionDescription ?? ""
        self.amount = entity.amount as Decimal
        self.category = entity.category
        self.vatRate = VATRate(rawValue: entity.vatRate) ?? .standard
    }
}

extension TransactionEntity {
    func update(from transaction: Transaction) {
        self.id = transaction.id
        self.date = transaction.date
        self.transactionDescription = transaction.description
        self.amount = transaction.amount as NSDecimalNumber
        self.category = transaction.category
        self.vatRate = transaction.vatRate.rawValue
    }
}