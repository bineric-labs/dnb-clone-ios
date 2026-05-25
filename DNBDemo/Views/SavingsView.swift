import SwiftUI

struct SavingsView: View {
    @EnvironmentObject var mockData: MockData
    @State private var showNewGoal = false
    @State private var showSaveNow = false
    @State private var dismissGoalsCard = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Title area
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total balance")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("NOK 12 527")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 16)

                    // Breakdown card
                    VStack(spacing: 0) {
                        savingsRow(icon: "arrow.3.trianglepath", label: "Accounts", amount: "NOK 2 773", change: nil, positive: true, externalLink: false)
                        Divider().padding(.leading, 68)
                        savingsRow(icon: "chart.bar.fill", label: "Mutual funds", amount: "NOK 0", change: "+0", positive: true, externalLink: false)
                        Divider().padding(.leading, 68)
                        savingsRow(icon: "chart.line.uptrend.xyaxis", label: "Shares", amount: "NOK 9 753", change: "-8 515", positive: false, externalLink: false)
                        Divider().padding(.leading, 68)
                        savingsRow(icon: "brain.head.profile", label: "Pension", amount: "", change: nil, positive: true, externalLink: true)
                    }
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // Save now / New goal
                    HStack(spacing: 28) {
                        actionButton(icon: "pawprint", label: "Save now") { showSaveNow = true }
                        actionButton(icon: "scope", label: "New goal") { showNewGoal = true }
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 16)

                    // Savings goals card
                    if !dismissGoalsCard {
                        VStack(spacing: 12) {
                            HStack {
                                Spacer()
                                Button(action: { withAnimation { dismissGoalsCard = true } }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                            ZStack {
                                Circle()
                                    .fill(Color.dnbLightTeal)
                                    .frame(width: 80, height: 80)
                                Image(systemName: "building.columns.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(Color.dnbTeal)
                            }
                            Text("Here you will see your savings goals")
                                .font(.system(size: 13, weight: .semibold))
                                .multilineTextAlignment(.center)
                            Text("Is there something you want to save for?")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button(action: { showNewGoal = true }) {
                                Text("Create your first savings goal")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(Color.dnbTeal)
                                    .cornerRadius(24)
                            }
                        }
                        .padding(18)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Returns on funds
                    HStack {
                        Text("Returns on funds")
                            .font(.system(size: 13, weight: .semibold))
                        Spacer()
                        Button("Show in Spare") {}
                            .font(.system(size: 13))
                            .foregroundColor(Color.dnbTeal)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                    HStack(spacing: 12) {
                        ReturnsTile(label: "Last trading day", sub: "Friday", value: "NOK 0", pct: "0,00 %")
                        ReturnsTile(label: "Last 7 days", sub: "16/05-22/05", value: "NOK 0", pct: "0,00 %")
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // Spare banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                colors: [Color(hex: "#e8f5f0"), Color(hex: "#c8e8dc")],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                        VStack(spacing: 10) {
                            Text("💰").font(.system(size: 30))
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.dnbTeal)
                                    .frame(width: 52, height: 52)
                                Text("Spare")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text("Make your investments in Spare")
                                .font(.system(size: 13, weight: .bold))
                                .multilineTextAlignment(.center)
                            Text("Invest in mutual funds and shares, follow developments and reach your goals.")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                            Button(action: {}) {
                                Text("Make your investments in Spare")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(Color.dnbTeal)
                                    .cornerRadius(24)
                            }
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // Links
                    VStack(spacing: 0) {
                        ForEach(["Boligspar Ekstra", "Choose pension scheme", "Move pension to us", "Share savings account", "FAQ about savings", "Stock trading", "Digital adviser", "My investment advice"], id: \.self) { label in
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "globe")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.dnbTeal)
                                        .frame(width: 28)
                                    Text(label)
                                        .font(.system(size: 13))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 13)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 56)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .padding(.top, 8)
            }
            .background(Color.dnbBackground)
            .navigationTitle("Savings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color.dnbTeal)
                    }
                }
            }
        }
        .sheet(isPresented: $showNewGoal) { NewSavingsGoalSheet() }
        .sheet(isPresented: $showSaveNow) { SaveNowSheet() }
    }

    @ViewBuilder
    private func savingsRow(icon: String, label: String, amount: String, change: String?, positive: Bool, externalLink: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.dnbTeal)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 13))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.system(size: 13)).foregroundColor(.secondary)
                if !amount.isEmpty {
                    Text(amount).font(.system(size: 13, weight: .semibold))
                }
            }
            Spacer()
            if let change = change {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Returns")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text(change)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(positive ? Color.dnbTeal : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((positive ? Color.dnbTeal : Color.red).opacity(0.1))
                        .cornerRadius(8)
                }
            } else if externalLink {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            if !externalLink {
                Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.dnbLightTeal)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundColor(Color.dnbTeal)
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ReturnsTile: View {
    let label: String
    let sub: String
    let value: String
    let pct: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 13)).foregroundColor(.secondary)
            Text(value).font(.system(size: 13, weight: .bold)).padding(.top, 2)
            Text(sub).font(.system(size: 13)).foregroundColor(Color(.tertiaryLabel))
            HStack(alignment: .bottom) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 3)
                        .frame(width: 44, height: 44)
                    Text(pct).font(.system(size: 13)).foregroundColor(.secondary).multilineTextAlignment(.center)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.dnbTeal)
                        .frame(width: 28, height: 28)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 6)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}

struct NewSavingsGoalSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var goalName = ""
    @State private var targetAmount = ""
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle().fill(Color.dnbLightTeal).frame(width: 80, height: 80)
                    Image(systemName: "building.columns.fill").font(.system(size: 34)).foregroundColor(Color.dnbTeal)
                }.padding(.top, 24)
                Text("Create savings goal").font(.system(size: 13, weight: .bold))
                VStack(spacing: 14) {
                    TextField("Goal name (e.g. Holiday, Car)", text: $goalName)
                        .padding(14).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
                    HStack {
                        Text("NOK").foregroundColor(.secondary).padding(.leading, 14)
                        TextField("Target amount", text: $targetAmount).keyboardType(.decimalPad)
                        Spacer()
                    }
                    .padding(.vertical, 14).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
                }
                .padding(.horizontal, 24)
                Button(action: { dismiss() }) {
                    Text("Create goal").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(goalName.isEmpty ? Color.gray.opacity(0.4) : Color.dnbTeal).cornerRadius(14)
                }
                .disabled(goalName.isEmpty).padding(.horizontal, 24)
                Spacer()
            }
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Cancel") { dismiss() }.foregroundColor(Color.dnbTeal) } }
        }
        .presentationDetents([.medium, .large])
    }
}

struct SaveNowSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""
    @State private var selectedGoal = "Current Account"
    let goals = ["Current Account", "BSU", "Holiday fund", "Emergency fund"]
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount to save") {
                    HStack { Text("NOK").foregroundColor(.secondary); TextField("0,00", text: $amount).keyboardType(.decimalPad) }
                }
                Section("Transfer to") {
                    Picker("Account", selection: $selectedGoal) { ForEach(goals, id: \.self) { Text($0) } }
                        .pickerStyle(.menu).tint(Color.dnbTeal)
                }
            }
            .navigationTitle("Save now").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { dismiss() }.foregroundColor(Color.dnbTeal).fontWeight(.semibold) }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SavingsView().environmentObject(MockData.shared)
}
