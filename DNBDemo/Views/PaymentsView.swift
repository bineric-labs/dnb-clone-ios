import SwiftUI

struct PaymentsView: View {
    @State private var showTransfer = false
    @State private var showPay = false
    @State private var showScan = false
    @State private var segmentSelection = 0
    @State private var showApproveAlert = false
    @State private var showExpiredSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Quick Actions — left aligned, same style as Home
                    HStack(spacing: 24) {
                        QuickActionButton(icon: "arrow.left.arrow.right", label: "Transfer") { showTransfer = true }
                        QuickActionButton(icon: "wallet.bifold", label: "Pay") { showPay = true }
                        QuickActionButton(icon: "qrcode.viewfinder", label: "Scan") { showScan = true }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    // Segmented control
                    Picker("Filter", selection: $segmentSelection) {
                        Text("Date").tag(0)
                        Text("Account").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // Expired eInvoices row
                    HStack {
                        Text("Expired eInvoices (1)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        Spacer()
                        Button("Show") { showExpiredSheet = true }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.dnbTeal)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    // Date header
                    Text("20 June 2026")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                    // eInvoice card — dashed border
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Current Account (1503.82.71264)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.bottom, 10)

                        HStack(spacing: 12) {
                            Image(systemName: "arrow.2.squarepath")
                                .font(.system(size: 13))
                                .foregroundColor(Color.dnbTeal)
                                .frame(width: 24)
                            Text("Transportstyrelsen")
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Text("8,90")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.bottom, 14)

                        HStack {
                            Button(action: {}) {
                                Text("Edit")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.dnbTeal)
                            }
                            Spacer()
                            Button(action: { showApproveAlert = true }) {
                                Text("Approve")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color.dnbTeal)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.dnbTeal, lineWidth: 1.5))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])).foregroundColor(Color(.systemGray4)))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // Links section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Links")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)

                        VStack(spacing: 0) {
                            ForEach([
                                ("person.2", "Recipients"),
                                ("doc.text", "eInvoice"),
                                ("arrow.triangle.2.circlepath", "AvtaleGiro"),
                                ("calendar.badge.clock", "Standing orders"),
                                ("creditcard", "Subscriptions and services")
                            ], id: \.1) { icon, label in
                                Button(action: {}) {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.dnbLightTeal)
                                                .frame(width: 34, height: 34)
                                            Image(systemName: icon)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.dnbTeal)
                                        }
                                        Text(label)
                                            .font(.system(size: 13))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 13)
                                }
                                .buttonStyle(PlainButtonStyle())
                                if label != "Subscriptions and services" {
                                    Divider().padding(.leading, 64)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .background(Color.dnbBackground)
            .navigationTitle("Payments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "person.crop.rectangle")
                            .foregroundColor(Color.dnbTeal)
                            .font(.system(size: 13))
                            .padding(6)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .alert("Payment approved", isPresented: $showApproveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Payment of NOK 8,90 to Transportstyrelsen has been approved.")
        }
        .sheet(isPresented: $showTransfer) { TransferView() }
        .sheet(isPresented: $showPay) { PayView() }
        .sheet(isPresented: $showScan) { ScanView() }
        .sheet(isPresented: $showExpiredSheet) { ExpiredInvoicesSheet() }
    }
}

struct ExpiredInvoicesSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    ZStack {
                        Circle().fill(Color.orange.opacity(0.15)).frame(width: 48, height: 48)
                        Image(systemName: "exclamationmark.circle.fill").font(.system(size: 13)).foregroundColor(.orange)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hafslund Nett AS").font(.system(size: 13, weight: .semibold))
                        Text("Expired 15 May").font(.system(size: 13)).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("NOK 1 200,00").font(.system(size: 13, weight: .semibold))
                }
                HStack(spacing: 10) {
                    Button(action: { dismiss() }) {
                        Text("Reject").font(.system(size: 13, weight: .medium)).foregroundColor(.red)
                            .frame(maxWidth: .infinity).padding(.vertical, 10).background(Color.red.opacity(0.1)).cornerRadius(12)
                    }
                    Button(action: { dismiss() }) {
                        Text("Pay anyway").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 10).background(Color.dnbTeal).cornerRadius(12)
                    }
                }
                Spacer()
            }
            .padding(16)
            .background(Color.dnbBackground)
            .navigationTitle("Expired eInvoices").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() }.foregroundColor(Color.dnbTeal) } }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    PaymentsView().environmentObject(MockData.shared)
}
