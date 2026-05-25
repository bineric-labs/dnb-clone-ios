import SwiftUI

struct TransferView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mockData: MockData
    @State private var amount = ""
    @State private var showToAccountPicker = false
    @State private var showConfirmation = false

    var fromAccount: Account { mockData.accounts[0] }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Amount input field
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Text(amount.isEmpty ? "NOK" : "NOK \(amount)")
                            .font(.system(size: 34, weight: .regular))
                            .foregroundColor(amount.isEmpty ? Color(.systemGray3) : .primary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.dnbTeal, lineWidth: 1.5)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }

                // Quick amount chips
                HStack(spacing: 10) {
                    ForEach([100, 500, 1000], id: \.self) { val in
                        Button(action: { amount = "\(val)" }) {
                            Text("+NOK \(val < 1000 ? "\(val)" : "1 000")")
                                .font(.system(size: 13))
                                .foregroundColor(Color.dnbTeal)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .overlay(Capsule().stroke(Color.dnbTeal, lineWidth: 1.2))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)

                // From / swap / To / Message / Date
                VStack(spacing: 0) {
                    // From
                    HStack(spacing: 12) {
                        Image(systemName: "bag")
                            .font(.system(size: 14))
                            .foregroundColor(Color.dnbTeal)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("From: \(fromAccount.name) (\(fromAccount.formattedBalance))")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            Text(fromAccount.number)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    // Swap icon
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 16))
                            .foregroundColor(Color.dnbTeal)
                        Spacer()
                    }
                    .padding(.vertical, 4)

                    Divider().padding(.leading, 52)

                    // To
                    Button(action: { showToAccountPicker = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "bag")
                                .font(.system(size: 14))
                                .foregroundColor(Color.dnbTeal)
                                .frame(width: 24)
                            Text("To: choose account")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Divider().padding(.leading, 52)

                    // Message
                    HStack(spacing: 12) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 14))
                            .foregroundColor(Color.dnbTeal)
                            .frame(width: 24)
                        Text("Message (optional)")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    Divider().padding(.leading, 52)

                    // Date
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                            .foregroundColor(Color.dnbTeal)
                            .frame(width: 24)
                        Text("Today")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .background(Color.white)
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                .padding(.horizontal, 16)

                Spacer()
            }
            .background(Color.dnbBackground)
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showConfirmation = true }) {
                        Text("Transfer")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(.systemGray3))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(20)
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
        .alert("Transfer Complete", isPresented: $showConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text("NOK \(amount) has been transferred from \(fromAccount.name).")
        }
    }
}

#Preview {
    TransferView().environmentObject(MockData.shared)
}
