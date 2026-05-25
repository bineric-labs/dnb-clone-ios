import SwiftUI

struct SpendingView: View {
    @EnvironmentObject var mockData: MockData
    @State private var timeSegment = 1
    @State private var selectedMonth = 5
    @State private var selectedCategory: SpendingCategory?
    @State private var showCategoryDetail = false
    @State private var showNewBudget = false
    @State private var showTagsSheet = false

    let months = ["2025", "January", "February", "March", "April", "May", "Last 30 days"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Year / Month toggle
                    Picker("Period", selection: $timeSegment) {
                        Text("Year").tag(0)
                        Text("Month").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)

                    // Month scroller
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(Array(months.enumerated()), id: \.offset) { index, month in
                                Button(action: { withAnimation { selectedMonth = index } }) {
                                    VStack(spacing: 4) {
                                        Text(month)
                                            .font(.system(size: 13, weight: selectedMonth == index ? .semibold : .regular))
                                            .foregroundColor(selectedMonth == index ? .primary : .secondary)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 8)
                                        Rectangle()
                                            .fill(selectedMonth == index ? Color.dnbTeal : Color.clear)
                                            .frame(height: 2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Total spending summary
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total spending")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("NOK 6 135")
                            .font(.system(size: 28, weight: .bold))
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.dnbTeal)
                            Text("12% less than last month")
                                .font(.system(size: 12))
                                .foregroundColor(Color.dnbTeal)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Three overlapping circles chart
                    ThreeCircleChart()
                        .frame(height: 180)
                        .padding(.horizontal, 16)

                    // Category list
                    VStack(spacing: 0) {
                        spendingRow(dot: Color.dnbTeal, label: "Fixed expenses", amount: "NOK 2 527") {
                            selectedCategory = .fixedExpenses; showCategoryDetail = true
                        }
                        Divider().padding(.leading, 20)
                        spendingRow(dot: Color(hex: "#7ecfb3"), label: "Savings", amount: "NOK 2 000") {
                            selectedCategory = .savings; showCategoryDetail = true
                        }
                        Divider().padding(.leading, 20)
                        spendingRow(dot: Color.dnbTeal.opacity(0.4), label: "Daily expenses", amount: "NOK 1 608") {
                            selectedCategory = .dailyExpenses; showCategoryDetail = true
                        }
                        Divider().padding(.leading, 20)
                        Button(action: {}) {
                            HStack {
                                Text("Not categorised since April 24th")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("0")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 13)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, 16)

                    // My #tags
                    Button(action: { showTagsSheet = true }) {
                        HStack(spacing: 12) {
                            Image(systemName: "tag")
                                .font(.system(size: 13))
                                .foregroundColor(Color.dnbTeal)
                            Text("My #tags")
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                            Spacer()
                            Text("0")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)

                    // Budgets header
                    HStack {
                        Text("Budgets")
                            .font(.system(size: 13, weight: .semibold))
                        Spacer()
                        Button("Show all") {}
                            .font(.system(size: 13))
                            .foregroundColor(Color.dnbTeal)
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .background(Color.dnbBackground)
            .navigationTitle("Spending")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color.dnbTeal)
                            .font(.system(size: 13))
                    }
                }
            }
        }
        .sheet(isPresented: $showCategoryDetail) {
            if let cat = selectedCategory { CategoryDetailSheet(category: cat) }
        }
        .sheet(isPresented: $showTagsSheet) { TagsSheet() }
    }

    @ViewBuilder
    private func spendingRow(dot: Color, label: String, amount: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Circle().fill(dot).frame(width: 10, height: 10)
                Text(label).font(.system(size: 13)).foregroundColor(.primary)
                Spacer()
                Text(amount).font(.system(size: 13, weight: .semibold))
                Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Three Circle Chart
struct ThreeCircleChart: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.dnbTeal.opacity(0.9))
                .frame(width: animate ? 90 : 0, height: animate ? 90 : 0)
                .overlay(VStack(spacing: 0) {
                    Text("42%").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    Text("Fixed").font(.system(size: 13)).foregroundColor(.white.opacity(0.8))
                })
                .offset(x: 0, y: -30)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animate)

            Circle()
                .fill(Color.dnbTeal.opacity(0.6))
                .frame(width: animate ? 76 : 0, height: animate ? 76 : 0)
                .overlay(VStack(spacing: 0) {
                    Text("33%").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    Text("Daily").font(.system(size: 13)).foregroundColor(.white.opacity(0.8))
                })
                .offset(x: -38, y: 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: animate)

            Circle()
                .fill(Color(hex: "#7ecfb3").opacity(0.8))
                .frame(width: animate ? 76 : 0, height: animate ? 76 : 0)
                .overlay(VStack(spacing: 0) {
                    Text("25%").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    Text("Savings").font(.system(size: 13)).foregroundColor(.white.opacity(0.8))
                })
                .offset(x: 38, y: 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: animate)
        }
        .onAppear { animate = true }
    }
}

// MARK: - Category Detail Sheet
struct CategoryDetailSheet: View {
    @EnvironmentObject var mockData: MockData
    let category: SpendingCategory
    @Environment(\.dismiss) var dismiss

    var transactions: [Transaction] { mockData.transactions.filter { $0.category == category } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, tx in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(Color.dnbLightTeal).frame(width: 42, height: 42)
                                Image(systemName: tx.icon).foregroundColor(Color.dnbTeal)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tx.merchant).font(.system(size: 13))
                                Text(tx.formattedDate).font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(tx.formattedAmount).font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        if index < transactions.count - 1 { Divider().padding(.leading, 74) }
                    }
                }
            }
            .navigationTitle(category.rawValue).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() }.foregroundColor(Color.dnbTeal) } }
        }
        .presentationDetents([.large, .medium])
    }
}

struct TagsSheet: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "tag.fill").font(.system(size: 48)).foregroundColor(Color.dnbTeal).padding(.top, 40)
                Text("My #tags").font(.system(size: 13, weight: .bold))
                Text("Tag your transactions to get better insights into your spending habits.")
                    .font(.system(size: 13)).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal, 32)
                Button(action: { dismiss() }) {
                    Text("Create first tag").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16).background(Color.dnbTeal).cornerRadius(14)
                }
                .padding(.horizontal, 32)
                Spacer()
            }
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() }.foregroundColor(Color.dnbTeal) } }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SpendingView().environmentObject(MockData.shared)
}
