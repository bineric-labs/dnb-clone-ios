import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String

    enum Role { case user, assistant }
}

struct AIAssistantView: View {
    @EnvironmentObject var mockData: MockData
    @Environment(\.dismiss) var dismiss
    @StateObject private var aiService = ClaudeService()

    @State private var messages: [ChatMessage] = []
    @State private var input = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let teal = Color(hex: "#1d5c4a")
    private let lightTeal = Color(hex: "#e6f4ef")

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat history
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if messages.isEmpty {
                                suggestionCards
                            }
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }
                            if isLoading {
                                TypingIndicator()
                                    .id("typing")
                            }
                            if let err = errorMessage {
                                Text(err)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
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

                Divider()

                // Input bar
                HStack(spacing: 10) {
                    TextField("Ask about your finances…", text: $input, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        .font(.system(size: 15))

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(input.trimmingCharacters(in: .whitespaces).isEmpty ? Color(.systemGray4) : teal)
                    }
                    .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(teal)
                }
            }
        }
    }

    // MARK: - Suggestion cards

    private var suggestionCards: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundColor(teal)
                Text("Ask me anything about\nyour finances")
                    .font(.system(size: 15, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)

            VStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { s in
                    Button(action: { input = s; sendMessage() }) {
                        HStack {
                            Text(s)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
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
                let reply = try await aiService.ask(question: text, context: buildContext())
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

    // MARK: - Context builder

    private func buildContext() -> String {
        var lines: [String] = []

        lines.append("ACCOUNTS:")
        for a in mockData.accounts {
            lines.append("  - \(a.name) (\(a.number)): \(a.formattedBalance)")
        }

        lines.append("\nRECENT TRANSACTIONS (last 14 days):")
        let sorted = mockData.transactions.sorted { $0.date > $1.date }
        for t in sorted {
            lines.append("  - \(t.formattedDate) \(t.merchant): \(t.formattedAmount) [\(t.category.rawValue)]")
        }

        lines.append("\nMONTHLY SUMMARY:")
        lines.append("  Income: NOK \(Int(mockData.monthlyIncome))")
        lines.append("  Spending: NOK \(Int(mockData.monthlySpending))")
        lines.append("  Left over: NOK \(Int(mockData.leftOver))")

        lines.append("\nSAVINGS:")
        lines.append("  Total savings balance: NOK \(Int(mockData.totalSavingsBalance))")
        lines.append("  Shares value: NOK \(Int(mockData.sharesBalance)) (P&L: NOK \(Int(mockData.sharesChange)))")

        return lines.joined(separator: "\n")
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    private let teal = Color(hex: "#2a6b66")

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user { Spacer(minLength: 40) }

            if message.role == .assistant {
                ZStack {
                    Circle().fill(Color.dnbLightTeal).frame(width: 28, height: 28)
                    Image(systemName: "sparkles").font(.system(size: 11)).foregroundColor(Color.dnbTeal)
                }
            }

            if message.role == .user {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(teal)
                    .cornerRadius(18)
            } else {
                FormattedAssistantText(text: message.text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }

            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }
}

struct FormattedAssistantText: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, para in
                if para.hasPrefix("• ") {
                    HStack(alignment: .top, spacing: 6) {
                        Text("•").font(.system(size: 13)).foregroundColor(Color.dnbTeal)
                        renderedText(para.dropFirst(2).description)
                    }
                } else if !para.isEmpty {
                    renderedText(para)
                }
            }
        }
    }

    private var paragraphs: [String] {
        text
            .components(separatedBy: "\n")
            .map { line in
                // convert "- item" to bullet
                line.hasPrefix("- ") ? "• " + line.dropFirst(2) : line
            }
    }

    @ViewBuilder
    private func renderedText(_ str: String) -> some View {
        if let attributed = try? AttributedString(markdown: str) {
            Text(attributed)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(str)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.3 : 0.8)
                        .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15), value: phase)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(18)
            Spacer(minLength: 60)
        }
        .onAppear { phase = 1 }
    }
}
