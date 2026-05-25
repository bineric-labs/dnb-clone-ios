import SwiftUI

// MARK: - Models

struct Account: Identifiable {
    let id = UUID()
    let name: String
    let number: String
    let balance: Double
    let currency: String
    let type: AccountType

    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: abs(balance))) ?? "0"
        if currency == "NOK" {
            return "NOK \(number)"
        } else if currency == "EUR" {
            return "€\(number)"
        }
        return "\(currency) \(number)"
    }

    enum AccountType {
        case current, savings, euro, investment
    }
}

struct Transaction: Identifiable {
    let id = UUID()
    let merchant: String
    let amount: Double
    let date: Date
    let category: SpendingCategory
    let icon: String

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        let number = formatter.string(from: NSNumber(value: abs(amount))) ?? "0"
        return amount < 0 ? "-NOK \(number)" : "NOK \(number)"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

enum SpendingCategory: String, CaseIterable {
    case fixedExpenses = "Fixed expenses"
    case savings = "Savings"
    case dailyExpenses = "Daily expenses"
    case transport = "Transport"
    case food = "Food & dining"
    case entertainment = "Entertainment"
}

struct SavingsGoal: Identifiable {
    let id = UUID()
    let name: String
    let targetAmount: Double
    let currentAmount: Double

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
}

struct PaymentItem: Identifiable {
    let id = UUID()
    let recipient: String
    let amount: Double
    let dueDate: Date
    let isPending: Bool

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "0,00"
    }
}

// MARK: - Mock Data

class MockData: ObservableObject {
    static let shared = MockData()

    let accounts: [Account] = [
        Account(name: "Current Account", number: "1503.82.71264", balance: 34250, currency: "NOK", type: .current),
        Account(name: "Euro Account", number: "1687.44.20938", balance: 8, currency: "EUR", type: .euro),
        Account(name: "Brukskonto", number: "1742.19.83605", balance: 0, currency: "NOK", type: .savings),
        Account(name: "Aksjesparekonto", number: "9841.56.30127", balance: 0, currency: "NOK", type: .investment)
    ]

    let transactions: [Transaction] = [
        Transaction(merchant: "Rema 1000", amount: -234, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, category: .dailyExpenses, icon: "cart.fill"),
        Transaction(merchant: "Kiwi Majorstuen", amount: -189, date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, category: .dailyExpenses, icon: "cart.fill"),
        Transaction(merchant: "Spotify", amount: -109, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, category: .fixedExpenses, icon: "music.note"),
        Transaction(merchant: "Netflix", amount: -149, date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, category: .fixedExpenses, icon: "tv.fill"),
        Transaction(merchant: "Hafslund", amount: -1200, date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, category: .fixedExpenses, icon: "bolt.fill"),
        Transaction(merchant: "Ruter", amount: -399, date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, category: .transport, icon: "tram.fill"),
        Transaction(merchant: "BSU Sparing", amount: -2000, date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, category: .savings, icon: "building.columns.fill"),
        Transaction(merchant: "Meny", amount: -456, date: Calendar.current.date(byAdding: .day, value: -8, to: Date())!, category: .dailyExpenses, icon: "cart.fill"),
        Transaction(merchant: "Gyldendal", amount: -299, date: Calendar.current.date(byAdding: .day, value: -9, to: Date())!, category: .entertainment, icon: "book.fill"),
        Transaction(merchant: "Sats", amount: -449, date: Calendar.current.date(byAdding: .day, value: -11, to: Date())!, category: .fixedExpenses, icon: "figure.run"),
        Transaction(merchant: "7-Eleven", amount: -89, date: Calendar.current.date(byAdding: .day, value: -12, to: Date())!, category: .dailyExpenses, icon: "cup.and.saucer.fill"),
        Transaction(merchant: "Vipps overføring", amount: -500, date: Calendar.current.date(byAdding: .day, value: -13, to: Date())!, category: .dailyExpenses, icon: "arrow.up.circle.fill"),
        Transaction(merchant: "Internett Telenor", amount: -599, date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!, category: .fixedExpenses, icon: "wifi"),
        Transaction(merchant: "Coop Extra", amount: -312, date: Calendar.current.date(byAdding: .day, value: -15, to: Date())!, category: .dailyExpenses, icon: "cart.fill")
    ]

    var fixedExpensesTransactions: [Transaction] {
        transactions.filter { $0.category == .fixedExpenses }
    }

    var savingsTransactions: [Transaction] {
        transactions.filter { $0.category == .savings }
    }

    var dailyExpensesTransactions: [Transaction] {
        transactions.filter { $0.category == .dailyExpenses }
    }

    let pendingPayments: [PaymentItem] = [
        PaymentItem(recipient: "Elvia AS", amount: 0.00, dueDate: Date(), isPending: true),
        PaymentItem(recipient: "Telenor AS", amount: 599.00, dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, isPending: true)
    ]

    let savingsGoals: [SavingsGoal] = []

    let usdToNok: Double = 9.26
    let totalSavingsBalance: Double = 12527
    let accountsBalance: Double = 2773
    let mutualFundsBalance: Double = 0
    let sharesBalance: Double = 9753
    let sharesChange: Double = -8515

    let monthlyIncome: Double = 34250
    let monthlySpending: Double = 25700
    var leftOver: Double { monthlyIncome - monthlySpending }
}
