import SwiftUI

struct AIView: View {
    @EnvironmentObject var mockData: MockData
    @StateObject private var assistant = ClaudeService()

    @State private var messages: [ChatMessage] = []
    @State private var input = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        // Spending forecast card at the top
                        SpendingForecastCard()
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        Divider().padding(.horizontal, 16)

                        // Chat area
                        LazyVStack(spacing: 12) {
                            if messages.isEmpty {
                                suggestionCards
                                    .padding(.horizontal, 16)
                            }
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                                    .padding(.horizontal, 16)
                            }
                            if isLoading {
                                TypingIndicator()
                                    .id("typing")
                                    .padding(.horizontal, 16)
                            }
                            if let err = errorMessage {
                                Text(err)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                            }
                        }
                        // Extra bottom padding so last message clears input bar + tab bar
                        .padding(.bottom, 120)
                    }
                }
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onChange(of: isLoading) {
                    if isLoading {
                        withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                    }
                }
            }
            .background(Color.dnbBackground)
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color.dnbTeal)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if !messages.isEmpty {
                        Button(action: {
                            withAnimation { messages = []; errorMessage = nil }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .medium))
                                Text("Home")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(Color.dnbTeal)
                        }
                    }
                }
            }
            // Input bar pinned above tab bar
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 10) {
                        TextField("Ask about your finances…", text: $input, axis: .vertical)
                            .lineLimit(1...4)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .font(.system(size: 13))

                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(input.trimmingCharacters(in: .whitespaces).isEmpty
                                                 ? Color(.systemGray4) : Color.dnbTeal)
                        }
                        .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    // Space for the custom tab bar
                    Color(.systemBackground).frame(height: 55)
                }
            }
        }
        .environmentObject(mockData)
    }

    // MARK: - Suggestion cards

    private var suggestionCards: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundColor(Color.dnbTeal)
                Text("Ask me anything about\nyour finances")
                    .font(.system(size: 13, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 12)

            VStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { s in
                    Button(action: { input = s; sendMessage() }) {
                        HStack {
                            Text(s)
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            }
        }
    }

    private let suggestions = [
        "How much did I spend this month?",
        "What are my biggest expenses?",
        "Can I afford a vacation in July?",
        "How is my savings looking?",
        "Summarise my finances"
    ]

    // MARK: - Send

    private func sendMessage() {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !isLoading else { return }
        input = ""
        errorMessage = nil
        messages.append(ChatMessage(role: .user, text: text))
        isLoading = true

        Task {
            do {
                let reply = try await assistant.ask(question: text, context: buildContext())
                await MainActor.run {
                    isLoading = false
                    messages.append(ChatMessage(role: .assistant, text: reply))
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }

    private func buildContext() -> String {
        var lines: [String] = []
        lines.append("ACCOUNTS:")
        for a in mockData.accounts {
            lines.append("  - \(a.name) (\(a.number)): \(a.formattedBalance)")
        }
        lines.append("\nRECENT TRANSACTIONS (last 14 days):")
        for t in mockData.transactions.sorted(by: { $0.date > $1.date }) {
            lines.append("  - \(t.formattedDate) \(t.merchant): \(t.formattedAmount) [\(t.category.rawValue)]")
        }
        lines.append("\nMONTHLY SUMMARY:")
        lines.append("  Income: NOK \(Int(mockData.monthlyIncome))")
        lines.append("  Spending: NOK \(Int(mockData.monthlySpending))")
        lines.append("  Left over: NOK \(Int(mockData.leftOver))")
        return lines.joined(separator: "\n")
    }
}

#Preview {
    AIView().environmentObject(MockData.shared)
}
