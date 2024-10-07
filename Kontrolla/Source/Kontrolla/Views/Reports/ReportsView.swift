import SwiftUI

struct ReportsView: View {
    @ObservedObject var transactionStore: TransactionStore
    @State private var selectedReport: ReportType = .profitAndLoss
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate = Date()
    
    var body: some View {
        VStack {
            Text("Financial Reports")
                .font(.largeTitle)
                .padding()
            
            Picker("Report Type", selection: $selectedReport) {
                ForEach(ReportType.allCases, id: \.self) { reportType in
                    Text(reportType.description).tag(reportType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .padding(.horizontal)
            
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                .padding(.horizontal)
            
            ScrollView {
                switch selectedReport {
                case .profitAndLoss:
                    ProfitAndLossView(transactions: filteredTransactions)
                case .balanceSheet:
                    BalanceSheetView(transactions: filteredTransactions)
                case .vatReport:
                    VATReportView(transactions: filteredTransactions)
                }
            }
        }
    }
    
    var filteredTransactions: [Transaction] {
        transactionStore.transactions.filter { transaction in
            (startDate...endDate).contains(transaction.date)
        }
    }
}

enum ReportType: CaseIterable {
    case profitAndLoss
    case balanceSheet
    case vatReport
    
    var description: String {
        switch self {
        case .profitAndLoss: return "Profit & Loss"
        case .balanceSheet: return "Balance Sheet"
        case .vatReport: return "VAT Report"
        }
    }
}

struct ProfitAndLossView: View {
    let transactions: [Transaction]
    
    var income: Decimal {
        transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var expenses: Decimal {
        transactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }
    
    var netProfit: Decimal {
        income - expenses
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Profit & Loss Statement")
                .font(.headline)
            
            Group {
                Text("Income: \(income, format: .currency(code: "SEK"))")
                Text("Expenses: \(expenses, format: .currency(code: "SEK"))")
                Text("Net Profit: \(netProfit, format: .currency(code: "SEK"))")
                    .fontWeight(.bold)
            }
            .font(.subheadline)
        }
        .padding()
    }
}

struct BalanceSheetView: View {
    let transactions: [Transaction]
    
    var assets: Decimal {
        transactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
    }
    
    var liabilities: Decimal {
        transactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
    }
    
    var equity: Decimal {
        assets - liabilities
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Balance Sheet")
                .font(.headline)
            
            Group {
                Text("Assets: \(assets, format: .currency(code: "SEK"))")
                Text("Liabilities: \(liabilities, format: .currency(code: "SEK"))")
                Text("Equity: \(equity, format: .currency(code: "SEK"))")
                    .fontWeight(.bold)
            }
            .font(.subheadline)
        }
        .padding()
    }
}

struct VATReportView: View {
    let transactions: [Transaction]
    
    var totalVAT: Decimal {
        transactions.reduce(0) { $0 + $1.vatAmount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("VAT Report")
                .font(.headline)
            
            Text("Total VAT: \(totalVAT, format: .currency(code: "SEK"))")
                .font(.subheadline)
            
            List {
                ForEach(VATRate.allCases, id: \.self) { rate in
                    VATRateRowView(transactions: transactions, rate: rate)
                }
            }
        }
        .padding()
    }
}

struct VATRateRowView: View {
    let transactions: [Transaction]
    let rate: VATRate
    
    var vatAmount: Decimal {
        transactions.filter { $0.vatRate == rate }.reduce(0) { $0 + $1.vatAmount }
    }
    
    var body: some View {
        HStack {
            Text(rate.description)
            Spacer()
            Text(vatAmount, format: .currency(code: "SEK"))
        }
    }
}