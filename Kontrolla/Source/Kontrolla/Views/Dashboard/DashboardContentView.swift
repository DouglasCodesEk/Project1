import SwiftUI

struct DashboardContentView: View {
    @ObservedObject var transactionStore: TransactionStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Financial Overview")
                    .font(.largeTitle)
                    .padding(.bottom)
                
                FinancialSummaryView(transactions: transactionStore.transactions)
                
                RecentTransactionsView(transactions: transactionStore.transactions)
                
                VATSummaryView(transactions: transactionStore.transactions)
            }
            .padding()
        }
    }
}

struct FinancialSummaryView: View {
    let transactions: [Transaction]
    
    var totalIncome: Decimal {
        transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Decimal {
        transactions.filter { $0.amount < 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Decimal {
        totalIncome + totalExpenses
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Financial Summary")
                .font(.headline)
            
            HStack {
                SummaryItemView(title: "Income", amount: totalIncome, color: .green)
                SummaryItemView(title: "Expenses", amount: abs(totalExpenses), color: .red)
                SummaryItemView(title: "Balance", amount: balance, color: balance >= 0 ? .blue : .red)
            }
        }
    }
}

struct SummaryItemView: View {
    let title: String
    let amount: Decimal
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
            Text(amount, format: .currency(code: "SEK"))
                .font(.headline)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct RecentTransactionsView: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Transactions")
                .font(.headline)
            
            ForEach(transactions.prefix(5)) { transaction in
                TransactionRowView(transaction: transaction)
            }
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.subheadline)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.amount, format: .currency(code: "SEK"))
                .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }
        .padding(.vertical, 5)
    }
}

struct VATSummaryView: View {
    let transactions: [Transaction]
    
    var totalVAT: Decimal {
        transactions.reduce(0) { $0 + $1.vatAmount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("VAT Summary")
                .font(.headline)
            
            Text("Total VAT: \(totalVAT, format: .currency(code: "SEK"))")
                .font(.subheadline)
        }
    }
}