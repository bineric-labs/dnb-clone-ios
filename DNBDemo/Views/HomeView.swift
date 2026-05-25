import SwiftUI
import Charts

extension NumberFormatter {
    func then(_ configure: (NumberFormatter) -> Void) -> NumberFormatter {
        configure(self); return self
    }
}

struct HomeView: View {
    @EnvironmentObject var mockData: MockData
    @State private var showTransfer = false
    @State private var showPay = false
    @State private var showScan = false
    @State private var showCustomise = false
    @State private var selectedAccount: Account?
    @State private var currentApprovalIndex = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Icon buttons row
                    HStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Button(action: {}) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(.primary)
                                    .frame(width: 38, height: 38)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Button(action: {}) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell")
                                        .font(.system(size: 13))
                                        .foregroundColor(.primary)
                                        .frame(width: 38, height: 38)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 1)
                                    Text("19")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.red)
                                        .clipShape(Capsule())
                                        .offset(x: 4, y: -2)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                    // Page title
                    Text("Home")
                        .font(.system(size: 22, weight: .regular))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 2)
                        .padding(.bottom, 4)

                    // Balance Card
                    BalanceCardView()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)

                    // For Approval
                    VStack(alignment: .leading, spacing: 8) {
                        Text("For approval (\(mockData.pendingPayments.count))")
                            .font(.system(size: 13, weight: .bold))
                            .padding(.horizontal, 16)
                        ApprovalCardView(currentIndex: $currentApprovalIndex)
                            .padding(.horizontal, 16)
                        // Page dots
                        HStack(spacing: 6) {
                            ForEach(0..<mockData.pendingPayments.count, id: \.self) { i in
                                Circle()
                                    .fill(i == currentApprovalIndex ? Color.primary : Color(.systemGray4))
                                    .frame(width: 7, height: 7)
                                    .animation(.spring(response: 0.3), value: currentApprovalIndex)
                                    .onTapGesture { withAnimation { currentApprovalIndex = i } }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Quick Actions (frameless)
                    QuickActionsRow(
                        showTransfer: $showTransfer,
                        showPay: $showPay,
                        showScan: $showScan
                    )
                    .padding(.horizontal, 16)

                    // Accounts Section (no wrapper card)
                    AccountsSectionView(selectedAccount: $selectedAccount)
                        .padding(.horizontal, 16)

                    // Currency Converter
                    CurrencyConverterWidget()
                        .padding(.horizontal, 16)

                    // Links Section
                    LinksSection(onCustomise: { showCustomise = true })
                        .padding(.horizontal, 16)

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .background(Color.dnbBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
        }
        .sheet(isPresented: $showTransfer) {
            TransferView()
        }
        .sheet(isPresented: $showPay) {
            PayView()
        }
        .sheet(isPresented: $showScan) {
            ScanView()
        }
        .sheet(item: $selectedAccount) { account in
            AccountDetailView(account: account)
        }
        .sheet(isPresented: $showCustomise) {
            CustomiseFrontPageView()
        }
    }
}

// MARK: - Balance Card
struct BalanceCardView: View {
    @State private var animateRing = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(Color(hex: "#2a6b66"))

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Left over this month")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    Text("NOK 3")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)
                    Text("Current Account")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer().frame(height: 8)
                    Text("No remaining payments")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color(hex: "#256660"))
                        .frame(width: 76, height: 76)
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 76, height: 76)
                    Circle()
                        .trim(from: 0, to: animateRing ? 0.27 : 0)
                        .stroke(Color(hex: "#5ecfa0"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 76, height: 76)
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(x: -1)
                        .animation(.easeInOut(duration: 1.2), value: animateRing)
                    VStack(spacing: 1) {
                        Text("8 d").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        Text("left").font(.system(size: 13)).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .onAppear { animateRing = true }
    }
}

// MARK: - Approval Card
struct ApprovalCardView: View {
    @EnvironmentObject var mockData: MockData
    @Binding var currentIndex: Int
    @State private var showEditSheet = false
    @State private var showChangeAmount = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.dnbNavy)

            VStack(alignment: .leading, spacing: 0) {
                // Account + date row
                HStack {
                    Text("Current Account (1503.82.71264)")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text("May \(20 + currentIndex)")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.bottom, 5)

                // Recipient + amount
                HStack(alignment: .center) {
                    Text(mockData.pendingPayments[currentIndex].recipient)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("NOK \(mockData.pendingPayments[currentIndex].formattedAmount)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 1)
                    .padding(.bottom, 10)

                // Action buttons
                HStack {
                    Button(action: { showEditSheet = true }) {
                        Text("Edit")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Button(action: { showChangeAmount = true }) {
                        Text("Change amount")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.dnbTeal)
                            .cornerRadius(20)
                    }
                }
                .padding(.bottom, 10)

            }
            .padding(16)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 {
                        withAnimation { currentIndex = min(currentIndex + 1, mockData.pendingPayments.count - 1) }
                    } else if value.translation.width > 50 {
                        withAnimation { currentIndex = max(currentIndex - 1, 0) }
                    }
                }
        )
        .sheet(isPresented: $showEditSheet) {
            EditPaymentSheet(payment: mockData.pendingPayments[currentIndex])
        }
        .sheet(isPresented: $showChangeAmount) {
            ChangeAmountSheet(payment: mockData.pendingPayments[currentIndex])
        }
    }
}

// MARK: - Quick Actions
struct QuickActionsRow: View {
    @Binding var showTransfer: Bool
    @Binding var showPay: Bool
    @Binding var showScan: Bool

    var body: some View {
        HStack(spacing: 24) {
            QuickActionButton(icon: "arrow.left.arrow.right", label: "Transfer") {
                showTransfer = true
            }
            QuickActionButton(icon: "wallet.bifold", label: "Pay") {
                showPay = true
            }
            QuickActionButton(icon: "qrcode.viewfinder", label: "Scan") {
                showScan = true
            }
            Spacer()
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.dnbTeal)
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                }
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Accounts Section
struct AccountsSectionView: View {
    @EnvironmentObject var mockData: MockData
    @Binding var selectedAccount: Account?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Accounts")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button(action: {}) {
                    Text("Show all")
                        .font(.system(size: 13))
                        .foregroundColor(Color.dnbTeal)
                }
            }
            .padding(.bottom, 10)

            VStack(spacing: 0) {
                ForEach(Array(mockData.accounts.enumerated()), id: \.element.id) { index, account in
                    Button(action: { selectedAccount = account }) {
                        HStack(spacing: 12) {
                            Image(systemName: accountIcon(for: account.type))
                                .font(.system(size: 13))
                                .foregroundColor(Color.dnbTeal)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(account.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(.primary)
                                Text(account.number)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(account.formattedBalance)
                                .font(.system(size: 13))
                                .foregroundColor(.primary)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(Color(.systemGray3))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                    }
                    .buttonStyle(PlainButtonStyle())

                    if index < mockData.accounts.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        }
    }

    func accountIcon(for type: Account.AccountType) -> String {
        switch type {
        case .current: return "bag"
        case .savings: return "building.columns"
        case .euro: return "eurosign"
        case .investment: return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - Currency Converter
struct CurrencyConverterWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "Do you want to get local currency abroad?" tip
            HStack {
                Text("Do you want to get the local currency when you're abroad?")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Button(action: {}) {
                    Text("Learn more")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.dnbTeal)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.dnbTeal, lineWidth: 1.5))
                }
            }
            .padding(16)

            Divider().padding(.horizontal, 16)

            // USD row
            HStack {
                HStack(spacing: 8) {
                    Text("🇺🇸").font(.system(size: 13))
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text("USD").font(.system(size: 13, weight: .medium))
                            Image(systemName: "chevron.down").font(.system(size: 13)).foregroundColor(.secondary)
                        }
                        Text("Amerikansk dollar").font(.system(size: 13)).foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text("1")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.dnbTeal)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            HStack {
                Spacer()
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 13))
                    .foregroundColor(Color.dnbTeal)
                Spacer()
            }

            // NOK row
            HStack {
                HStack(spacing: 8) {
                    Text("🇳🇴").font(.system(size: 13))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("NOK").font(.system(size: 13, weight: .medium))
                        Text("Norsk krone").font(.system(size: 13)).foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text("9,26")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.dnbTeal)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider().padding(.horizontal, 16)

            Text("Last updated: 22 May 2026 at 09:12")
                .font(.system(size: 13))
                .foregroundColor(Color(.tertiaryLabel))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Links Section
struct LinksSection: View {
    var onCustomise: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 0) {
            linkRow(icon: "lightbulb", label: "Info and tips", isExternal: false)
            Divider().padding(.leading, 56)
            // Spare row with branded green square icon
            Button(action: {}) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(Color.dnbTeal).frame(width: 28, height: 28)
                        Text("S").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    }
                    Text("Open DNB Spare").font(.system(size: 13)).foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right.square").font(.system(size: 13)).foregroundColor(.secondary)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())
            Divider().padding(.leading, 56)
            linkRow(icon: "headphones", label: "Customer service", isExternal: false)
            Divider().padding(.leading, 56)
            linkRow(icon: "globe", label: "Go to web version", isExternal: true)
            Divider().padding(.leading, 56)
            linkRow(icon: "envelope", label: "Inbox", isExternal: false)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)

        // Customise front page button
        Button(action: { onCustomise?() }) {
            HStack(spacing: 8) {
                Image(systemName: "pencil").font(.system(size: 13))
                Text("Customise front page").font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(Color.dnbTeal)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.dnbTeal, lineWidth: 1.5))
        }
    }

    @ViewBuilder
    private func linkRow(icon: String, label: String, isExternal: Bool) -> some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(Color.dnbTeal)
                    .frame(width: 28)
                Text(label).font(.system(size: 13)).foregroundColor(.primary)
                Spacer()
                Image(systemName: isExternal ? "arrow.up.right.square" : "chevron.right")
                    .font(.system(size: isExternal ? 13 : 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Payment Sheet
struct EditPaymentSheet: View {
    let payment: PaymentItem
    @Environment(\.dismiss) var dismiss
    @State private var recipient: String
    @State private var amount: String

    init(payment: PaymentItem) {
        self.payment = payment
        _recipient = State(initialValue: payment.recipient)
        _amount = State(initialValue: payment.formattedAmount)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipient") {
                    TextField("Recipient", text: $recipient)
                }
                Section("Amount") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { dismiss() }
                        .foregroundColor(Color.dnbTeal)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Change Amount Sheet
struct ChangeAmountSheet: View {
    let payment: PaymentItem
    @Environment(\.dismiss) var dismiss
    @State private var amount: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Change Amount")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.top, 24)

                Text(payment.recipient)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                TextField("New amount (NOK)", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 24)

                Button(action: { dismiss() }) {
                    Text("Confirm")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.dnbTeal)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Scan View
struct ScanView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 16)

            VStack(spacing: 12) {
                scanOption(label: "Take photo of bill")
                Divider()
                scanOption(label: "Select from photo gallery")
                Divider()
                scanOption(label: "Import from Files")
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 16)

            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Spacer()
        }
        .background(Color.dnbBackground)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    @ViewBuilder
    private func scanOption(label: String) -> some View {
        Button(action: { dismiss() }) {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
}

// MARK: - Customise Front Page
struct CustomiseFrontPageView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedModules = ["Money left over", "Accounts", "Currency converter", "Info and tips"]
    let hiddenModules = ["Property loans"]

    let moduleIcons: [String: String] = [
        "Money left over": "arrow.3.trianglepath",
        "Accounts": "bag",
        "Currency converter": "arrow.2.circlepath",
        "Info and tips": "lightbulb",
        "Property loans": "chart.bar"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Customise front page")
                            .font(.system(size: 24, weight: .bold))
                        Text("Choose which modules to display on the front page.\nTap Edit to remove a module.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Selected modules
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Selected modules")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Button("Edit") {}
                                .font(.system(size: 14))
                                .foregroundColor(Color.dnbTeal)
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            ForEach(Array(selectedModules.enumerated()), id: \.offset) { index, module in
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8).fill(Color.dnbLightTeal).frame(width: 32, height: 32)
                                        Image(systemName: moduleIcons[module] ?? "square")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.dnbTeal)
                                    }
                                    Text(module).font(.system(size: 14))
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 11)).foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 13)
                                if index < selectedModules.count - 1 { Divider().padding(.leading, 62) }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                        .padding(.horizontal, 16)
                    }

                    // Hidden modules
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hidden modules")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            ForEach(hiddenModules, id: \.self) { module in
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8).fill(Color.dnbLightTeal).frame(width: 32, height: 32)
                                        Image(systemName: moduleIcons[module] ?? "square")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.dnbTeal)
                                    }
                                    Text(module).font(.system(size: 14))
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 11)).foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 13)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Color.dnbBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle().fill(Color.dnbTeal).frame(width: 32, height: 32)
                            Image(systemName: "checkmark").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Pay View
struct PayView: View {
    @Environment(\.dismiss) var dismiss
    @State private var recipient = ""
    @State private var amount = ""
    @State private var message = ""
    @State private var showConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipient") {
                    TextField("Account number or name", text: $recipient)
                }
                Section("Payment details") {
                    HStack {
                        Text("NOK")
                            .foregroundColor(.secondary)
                        TextField("0,00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    TextField("Message (optional)", text: $message)
                }
            }
            .navigationTitle("Pay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        showConfirmation = true
                    }
                    .foregroundColor(Color.dnbTeal)
                    .fontWeight(.semibold)
                }
            }
            .alert("Payment sent!", isPresented: $showConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your payment to \(recipient.isEmpty ? "recipient" : recipient) has been sent.")
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - AI Insights Section

struct AIInsightsSection: View {
    var body: some View {
        SpendingForecastCard()
    }
}

struct SpendingForecastCard: View {
    @StateObject private var predictor = SpendingPredictor()

    // Actual cumulative spend day-by-day — starts climbing from day 8
    private let actual: [(day: Int, amount: Double)] = [
        (1, 189), (2, 378), (3, 378), (4, 567), (5, 756), (6, 756), (7, 945),
        (8, 1257), (9, 1557), (10, 1856), (11, 2305), (12, 2754), (13, 3203),
        (14, 3402), (15, 3802), (16, 4236), (17, 4670), (18, 4859),
        (19, 5048), (20, 5248), (21, 5437), (22, 5787), (23, 5976), (24, 6135)
    ]

    private let budget: Double = 7000
    private var eomValue: Double { predictor.forecastPoints.last?.amount ?? 0 }
    private var isOverspent: Bool { predictor.isReady && eomValue > budget }

    private var eomFormatted: String {
        guard predictor.isReady else { return "" }
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = " "
        fmt.maximumFractionDigits = 0
        let s = fmt.string(from: NSNumber(value: Int(eomValue))) ?? ""
        return "kr \(s)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.dnbTeal)
                        Text("ML Prediction")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.dnbTeal)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    Text("Spent this month")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        Text("kr 6 135")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                        if isOverspent {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 13))
                                Text("Overspent")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "#ff3b30"))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color(hex: "#ff3b30").opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Forecast EOM")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    if predictor.isReady {
                        Text(eomFormatted)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isOverspent ? Color(hex: "#ff3b30") : Color.dnbTeal)
                    } else {
                        ProgressView().scaleEffect(0.65).tint(Color.dnbTeal)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // Chart
            GeometryReader { geo in
                ForecastChartCanvas(
                    actual: actual,
                    forecast: predictor.forecastPoints,
                    width: geo.size.width,
                    height: geo.size.height,
                    lightMode: true
                )
            }
            .frame(height: 90)

            // X axis labels
            HStack {
                ForEach([1, 6, 11, 16, 21, 26, 31], id: \.self) { d in
                    Text("\(d)")
                        .font(.system(size: 13))
                        .foregroundColor(Color(.tertiaryLabel))
                    if d != 31 { Spacer() }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.dnbTeal.opacity(0.2), lineWidth: 1))
        )
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        .onAppear {
            predictor.train(currentDaySpend: actual.map { (day: $0.day, cumulative: $0.amount) })
        }
    }
}

struct ForecastChartCanvas: View {
    let actual: [(day: Int, amount: Double)]
    let forecast: [(day: Int, amount: Double)]
    let width: CGFloat
    let height: CGFloat
    var lightMode: Bool = false

    private let allDays = 31

    var body: some View {
        let lineColor = lightMode ? Color.dnbTeal : Color(hex: "#ff453a")
        let forecastLineColor = lightMode ? Color.dnbTeal.opacity(0.4) : Color.white.opacity(0.28)
        let forecastFillColor = lightMode ? Color.dnbTeal.opacity(0.05) : Color.white.opacity(0.07)

        Canvas { ctx, size in
            let maxVal = max(
                actual.map(\.amount).max() ?? 1,
                forecast.map(\.amount).max() ?? 1
            ) * 1.15

            func x(_ day: Int) -> CGFloat { CGFloat(day - 1) / CGFloat(allDays - 1) * size.width }
            func y(_ val: Double) -> CGFloat { size.height - CGFloat(val / maxVal) * size.height }

            // Forecast filled area
            if !forecast.isEmpty {
                var fPath = Path()
                fPath.move(to: CGPoint(x: x(forecast[0].day), y: size.height))
                fPath.addLine(to: CGPoint(x: x(forecast[0].day), y: y(forecast[0].amount)))
                for p in forecast.dropFirst() {
                    fPath.addLine(to: CGPoint(x: x(p.day), y: y(p.amount)))
                }
                fPath.addLine(to: CGPoint(x: x(forecast.last!.day), y: size.height))
                fPath.closeSubpath()
                ctx.fill(fPath, with: .color(forecastFillColor))

                var fLine = Path()
                fLine.move(to: CGPoint(x: x(forecast[0].day), y: y(forecast[0].amount)))
                for p in forecast.dropFirst() {
                    fLine.addLine(to: CGPoint(x: x(p.day), y: y(p.amount)))
                }
                ctx.stroke(fLine, with: .color(forecastLineColor),
                           style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
            }

            // Actual filled area
            if !actual.isEmpty {
                var aPath = Path()
                aPath.move(to: CGPoint(x: x(actual[0].day), y: size.height))
                for p in actual {
                    aPath.addLine(to: CGPoint(x: x(p.day), y: y(p.amount)))
                }
                aPath.addLine(to: CGPoint(x: x(actual.last!.day), y: size.height))
                aPath.closeSubpath()
                ctx.fill(aPath, with: .linearGradient(
                    Gradient(stops: [
                        .init(color: lineColor.opacity(0.3), location: 0),
                        .init(color: lineColor.opacity(0.0), location: 1)
                    ]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 0, y: size.height)
                ))

                var aLine = Path()
                aLine.move(to: CGPoint(x: x(actual[0].day), y: y(actual[0].amount)))
                for p in actual.dropFirst() {
                    aLine.addLine(to: CGPoint(x: x(p.day), y: y(p.amount)))
                }
                ctx.stroke(aLine, with: .color(lineColor),
                           style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Cashflow River Card

private struct CashflowEvent: Identifiable {
    let id = UUID()
    let day: Int
    let label: String
    let amount: Double
    let icon: String
    var isIncome: Bool { amount > 0 }
}

struct CashflowRiverCard: View {
    @State private var dragDay: Int? = nil
    @State private var dragLocation: CGFloat = 0
    @State private var animateIn = false

    private let today = 25
    private let totalDays = 31
    private let startBalance: Double = 24_318
    private let salary: Double = 38_500

    private let events: [CashflowEvent] = [
        CashflowEvent(day: 1,  label: "Husleie",       amount: -14_850, icon: "house.fill"),
        CashflowEvent(day: 1,  label: "Netflix",       amount: -179,    icon: "play.rectangle.fill"),
        CashflowEvent(day: 5,  label: "Electricity",   amount: -1_200,  icon: "bolt.fill"),
        CashflowEvent(day: 10, label: "Telenor",       amount: -599,    icon: "phone.fill"),
        CashflowEvent(day: 15, label: "Salary",        amount: 38_500,  icon: "banknote.fill"),
        CashflowEvent(day: 20, label: "DNB Boliglån",  amount: -9_430,  icon: "building.2.fill"),
        CashflowEvent(day: 25, label: "Gym",           amount: -549,    icon: "figure.run"),
        CashflowEvent(day: 28, label: "Hafslund",      amount: -1_200,  icon: "bolt.fill"),
        CashflowEvent(day: 30, label: "Spotify",       amount: -119,    icon: "music.note"),
    ]

    private var balancePoints: [(day: Int, balance: Double)] {
        var pts: [(day: Int, balance: Double)] = []
        var running = startBalance
        for d in 1...totalDays {
            let dayEvents = events.filter { $0.day == d }
            for e in dayEvents { running += e.amount }
            pts.append((day: d, balance: running))
        }
        return pts
    }

    private var selectedDay: Int { dragDay ?? today }
    private var selectedBalance: Double { balancePoints.first(where: { $0.day == selectedDay })?.balance ?? startBalance }
    private var selectedEvents: [CashflowEvent] { events.filter { $0.day == selectedDay } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cashflow")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Text(formatBalance(selectedBalance))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(selectedBalance < 0 ? Color(hex: "#ff3b30") : .primary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: selectedDay)
                    Text(selectedDay == today ? "Available now" : "Projected \(selectedDay) May")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                // Mini event badges for selected day
                if !selectedEvents.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach(selectedEvents.prefix(2)) { ev in
                            HStack(spacing: 4) {
                                Text(ev.isIncome ? "+" : "")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(ev.isIncome ? Color(hex: "#30d158") : Color(hex: "#ff3b30"))
                                + Text(formatShort(ev.amount))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(ev.isIncome ? Color(hex: "#30d158") : Color(hex: "#ff3b30"))
                                Image(systemName: ev.icon)
                                    .font(.system(size: 13))
                                    .foregroundColor(ev.isIncome ? Color(hex: "#30d158") : Color(hex: "#ff3b30"))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background((ev.isIncome ? Color(hex: "#30d158") : Color(hex: "#ff3b30")).opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .animation(.spring(response: 0.3), value: selectedDay)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // River chart
            GeometryReader { geo in
                let pts = balancePoints
                let maxVal = pts.map(\.balance).max() ?? 1
                let minVal = min(pts.map(\.balance).min() ?? 0, 0)
                let range = maxVal - minVal

                ZStack(alignment: .bottom) {
                    // River path
                    Canvas { ctx, size in
                        func x(_ day: Int) -> CGFloat { CGFloat(day - 1) / CGFloat(totalDays - 1) * size.width }
                        func y(_ val: Double) -> CGFloat {
                            let norm = (val - minVal) / range
                            return size.height - CGFloat(norm) * size.height * 0.85 - size.height * 0.05
                        }

                        // Zero line (if needed)
                        if minVal < 0 {
                            let zy = y(0)
                            var zLine = Path()
                            zLine.move(to: CGPoint(x: 0, y: zy))
                            zLine.addLine(to: CGPoint(x: size.width, y: zy))
                            ctx.stroke(zLine, with: .color(Color(hex: "#ff3b30").opacity(0.2)),
                                       style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        }

                        // Filled area
                        var fill = Path()
                        fill.move(to: CGPoint(x: x(pts[0].day), y: size.height))
                        for pt in pts {
                            fill.addLine(to: CGPoint(x: x(pt.day), y: y(pt.balance)))
                        }
                        fill.addLine(to: CGPoint(x: x(pts.last!.day), y: size.height))
                        fill.closeSubpath()
                        ctx.fill(fill, with: .linearGradient(
                            Gradient(stops: [
                                .init(color: Color.dnbTeal.opacity(animateIn ? 0.18 : 0), location: 0),
                                .init(color: Color.dnbTeal.opacity(0), location: 1)
                            ]),
                            startPoint: CGPoint(x: 0, y: 0),
                            endPoint: CGPoint(x: 0, y: size.height)
                        ))

                        // Past line (solid teal)
                        var pastLine = Path()
                        let pastPts = pts.filter { $0.day <= today }
                        if let first = pastPts.first {
                            pastLine.move(to: CGPoint(x: x(first.day), y: y(first.balance)))
                            for pt in pastPts.dropFirst() {
                                pastLine.addLine(to: CGPoint(x: x(pt.day), y: y(pt.balance)))
                            }
                        }
                        ctx.stroke(pastLine, with: .color(animateIn ? Color.dnbTeal : .clear),
                                   style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                        // Future line (dashed)
                        var futureLine = Path()
                        let futurePts = pts.filter { $0.day >= today }
                        if let first = futurePts.first {
                            futureLine.move(to: CGPoint(x: x(first.day), y: y(first.balance)))
                            for pt in futurePts.dropFirst() {
                                futureLine.addLine(to: CGPoint(x: x(pt.day), y: y(pt.balance)))
                            }
                        }
                        ctx.stroke(futureLine, with: .color(Color.dnbTeal.opacity(0.4)),
                                   style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [5, 4]))

                        // Today vertical line
                        let tx = x(today)
                        var todayLine = Path()
                        todayLine.move(to: CGPoint(x: tx, y: 0))
                        todayLine.addLine(to: CGPoint(x: tx, y: size.height))
                        ctx.stroke(todayLine, with: .color(Color.dnbTeal.opacity(0.25)),
                                   style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    }

                    // Event tick marks
                    ForEach(events) { ev in
                        let xFrac = CGFloat(ev.day - 1) / CGFloat(totalDays - 1)
                        let isPast = ev.day <= today
                        VStack(spacing: 0) {
                            Spacer()
                            Circle()
                                .fill(ev.isIncome
                                      ? Color(hex: "#30d158")
                                      : (isPast ? Color.dnbTeal : Color(.systemGray3)))
                                .frame(width: 6, height: 6)
                                .padding(.bottom, 2)
                        }
                        .frame(maxHeight: .infinity)
                        .position(x: xFrac * geo.size.width, y: geo.size.height - 5)
                    }

                    // Drag cursor
                    let cursorX: CGFloat = {
                        let d = dragDay ?? today
                        return CGFloat(d - 1) / CGFloat(totalDays - 1) * geo.size.width
                    }()
                    Rectangle()
                        .fill(Color.primary.opacity(0.15))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                        .position(x: cursorX, y: geo.size.height / 2)
                        .animation(.interactiveSpring(), value: selectedDay)

                    Circle()
                        .fill(Color.dnbTeal)
                        .frame(width: 10, height: 10)
                        .shadow(color: Color.dnbTeal.opacity(0.5), radius: 4)
                        .position(x: cursorX, y: {
                            let pts2 = balancePoints
                            let maxV = pts2.map(\.balance).max() ?? 1
                            let minV = min(pts2.map(\.balance).min() ?? 0, 0)
                            let rng = maxV - minV
                            let val = pts2.first(where: { $0.day == selectedDay })?.balance ?? startBalance
                            let norm = (val - minV) / rng
                            return geo.size.height - CGFloat(norm) * geo.size.height * 0.85 - geo.size.height * 0.05
                        }())
                        .animation(.interactiveSpring(), value: selectedDay)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { val in
                            let frac = max(0, min(1, val.location.x / geo.size.width))
                            let day = max(1, min(totalDays, Int(frac * CGFloat(totalDays - 1)) + 1))
                            dragDay = day
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.4)) { dragDay = nil }
                        }
                )
            }
            .frame(height: 100)
            .padding(.horizontal, 8)

            // Day labels
            HStack {
                ForEach([1, 8, 15, 22, 31], id: \.self) { d in
                    Text(d == 1 ? "1" : "\(d)")
                        .font(.system(size: 13))
                        .foregroundColor(d == today ? Color.dnbTeal : Color(.tertiaryLabel))
                        .fontWeight(d == today ? .semibold : .regular)
                    if d != 31 { Spacer() }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 4)

            // Upcoming events strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(events.filter { $0.day >= today }.sorted { $0.day < $1.day }) { ev in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: ev.icon)
                                    .font(.system(size: 13))
                                    .foregroundColor(ev.isIncome ? Color(hex: "#30d158") : .secondary)
                                Text(ev.day == today ? "Today" : "\(ev.day) May")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            Text(ev.label)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Text((ev.isIncome ? "+" : "") + formatShort(ev.amount))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(ev.isIncome ? Color(hex: "#30d158") : Color(hex: "#ff3b30"))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ev.isIncome
                                      ? Color(hex: "#30d158").opacity(0.08)
                                      : (ev.day == today ? Color.dnbTeal.opacity(0.07) : Color(.systemGray6)))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ev.day == today ? Color.dnbTeal.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 14)
            }
            .padding(.bottom, 14)
            .padding(.top, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.15)) { animateIn = true }
        }
    }

    private func formatBalance(_ val: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.groupingSeparator = " "
        fmt.maximumFractionDigits = 0
        let s = fmt.string(from: NSNumber(value: abs(Int(val)))) ?? "0"
        return (val < 0 ? "-" : "") + "NOK \(s)"
    }

    private func formatShort(_ val: Double) -> String {
        let abs = Swift.abs(val)
        if abs >= 1000 {
            let k = abs / 1000
            return String(format: k.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f k" : "%.1f k", k)
        }
        return String(format: "%.0f", abs)
    }
}

#Preview {
    HomeView()
        .environmentObject(MockData.shared)
}
