import Foundation

class CSVParser {
    static let shared = CSVParser()

    func parseCSV(at url: URL) {
        do {
            let data = try String(contentsOf: url)
            let rows = data.components(separatedBy: "\n")
            for row in rows {
                let columns = row.components(separatedBy: ",")
                // Map columns to your Transaction model
                let transaction = Transaction(
                    date: columns[0],
                    description: columns[1],
                    amount: Double(columns[2]) ?? 0.0
                )
                TransactionStore.shared.add(transaction: transaction)
            }
        } catch {
            print("Error reading CSV file: \(error.localizedDescription)")
        }
    }
}