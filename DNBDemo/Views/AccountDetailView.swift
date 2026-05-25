import SwiftUI

struct AccountDetailView: View {
    let account: Account
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mockData: MockData
    @State private var searchText = ""
    @State private var showTransfer = false

    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return mockData.transactions
        }
        return mockData.transactions.filter {
            $0.merchant.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Account Balance Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.dnbTeal)
                        VStack(spacing: 8) {
                            Text(account.name)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.8))
                            Text(account.formattedBalance)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            Text(account.number)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.15))
                                .cornerRadius(20)
                        }
                        .padding(24)
                    }
                    .frame(height: 160)
                    .padding(.horizontal, 16)

                    // Quick Actions
                    HStack(spacing: 0) {
                        QuickActionButton(icon: "arrow.left.arrow.right", label: "Transfer") {
                            showTransfer = true
                        }
                        QuickActionButton(icon: "doc.text.fill", label: "Pay") {}
                        QuickActionButton(icon: "info.circle.fill", label: "Details") {}
                    }
                    .padding(.vertical, 8)
                    .cardStyle()
                    .padding(.horizontal, 16)

                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search transactions", text: $searchText)
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)

                    // Transactions
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Transactions")
                            .font(.system(size: 17, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)

                        Divider().padding(.leading, 16)

                        ForEach(Array(filteredTransactions.enumerated()), id: \.element.id) { index, tx in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(tx.amount > 0 ? Color.green.opacity(0.12) : Color.dnbLightTeal)
                                        .frame(width: 42, height: 42)
                                    Image(systemName: tx.icon)
                                        .font(.system(size: 16))
                                        .foregroundColor(tx.amount > 0 ? .green : Color.dnbTeal)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tx.merchant)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                    Text(tx.formattedDate)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(tx.formattedAmount)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(tx.amount > 0 ? .green : .primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                            if index < filteredTransactions.count - 1 {
                                Divider().padding(.leading, 70)
                            }
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal, 16)

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .background(Color.dnbBackground)
            .navigationTitle(account.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color.dnbTeal)
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showTransfer) {
            TransferView()
        }
    }
}

#Preview {
    AccountDetailView(account: MockData.shared.accounts[0])
        .environmentObject(MockData.shared)
}
