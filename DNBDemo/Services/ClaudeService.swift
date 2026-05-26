import Foundation

class ClaudeService: ObservableObject {

    // Add your Bineric API key in Config.xcconfig:
    //   BINERIC_API_KEY = your-key-here
    // Get a free key at: https://platform.bineric.com
    private var apiKey: String? {
        if let key = Bundle.main.object(forInfoDictionaryKey: "BINERIC_API_KEY") as? String,
           !key.isEmpty, key != "$(BINERIC_API_KEY)" {
            return key
        }
        return nil
    }

    func ask(question: String, context: String) async throws -> String {
        if let key = apiKey {
            return try await liveResponse(question: question, context: context, apiKey: key)
        } else {
            try await Task.sleep(nanoseconds: 1_200_000_000)
            return Self.mockResponse(for: question.lowercased())
        }
    }

    // MARK: - Bineric API (OpenAI-compatible)

    private func liveResponse(question: String, context: String, apiKey: String) async throws -> String {
        let url = URL(string: "https://api.bineric.com/api/v1/ai/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let systemPrompt = """
        You are a friendly, concise personal finance assistant inside a banking app.
        You have access to the user's real account balances and recent transactions below.
        Answer in 2-5 sentences max. Use **bold** for key numbers. Use bullet points where helpful.
        Never make up numbers — only use what is in the context provided.
        Always respond in the same language the user writes in.

        USER'S FINANCIAL DATA:
        \(context)
        """

        let body: [String: Any] = [
            "model": "gpt-4o",
            "max_tokens": 512,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": question]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let errStr = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.apiError(errStr)
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded.choices.first?.message.content ?? "Sorry, I couldn't generate a response."
    }

    // MARK: - Response model (OpenAI-compatible format)

    private struct OpenAIResponse: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let message: Message
        }
        struct Message: Decodable {
            let content: String
        }
    }

    enum AIError: Error, LocalizedError {
        case apiError(String)
        var errorDescription: String? {
            if case .apiError(let msg) = self { return msg }
            return nil
        }
    }

    // MARK: - Mock responses (used when no API key is configured)

    private static func mockResponse(for q: String) -> String {
        if q.contains("spend") && (q.contains("month") || q.contains("this")) {
            return "This month you've spent **NOK 25 700** across all categories. Your biggest costs are fixed expenses like Hafslund (NOK 1 200), Sats (NOK 449), and internet (NOK 599), followed by daily expenses like grocery shopping at Rema, Kiwi, and Meny totalling around NOK 1 200."
        }
        if q.contains("biggest") || q.contains("largest") || q.contains("most") {
            return "Your top expenses this period:\n- **BSU savings transfer** — NOK 2 000\n- **Hafslund** (electricity) — NOK 1 200\n- **Internett Telenor** — NOK 599\n- **Ruter** (transport pass) — NOK 399\n- **Spotify + Netflix** — NOK 258 combined\n\nGroceries across Rema, Kiwi, Meny, and Coop Extra add up to ~NOK 1 200."
        }
        if q.contains("vacation") || q.contains("holiday") || q.contains("july") || q.contains("afford") {
            return "Based on your finances, a July holiday looks feasible. You have **NOK 34 250** in your current account and typically have **NOK 8 550** left over each month. If you set aside NOK 2 000/month now, you'd have a comfortable holiday budget by July."
        }
        if q.contains("saving") || q.contains("savings") {
            return "Your total savings stand at **NOK 12 527**:\n- Accounts: NOK 2 773\n- Shares: NOK 9 753 (down NOK 8 515 on paper)\n- Mutual funds: NOK 0\n\nYour BSU transfer of NOK 2 000 this month is great — keep it up for the tax benefit."
        }
        if q.contains("balance") || q.contains("account") || q.contains("how much") {
            return "Here's a snapshot of your accounts:\n- **Current Account**: NOK 34 250\n- **Euro Account**: €8\n- **Brukskonto**: NOK 0\n\nYour main spending account has a healthy balance heading into end of month."
        }
        if q.contains("subscri") || q.contains("fixed") || q.contains("recurring") {
            return "Your recurring fixed expenses total **NOK 2 457/month**:\n- Spotify: NOK 109\n- Netflix: NOK 149\n- Hafslund (electricity): NOK 1 200\n- Sats (gym): NOK 449\n- Telenor internet: NOK 599"
        }
        if q.contains("food") || q.contains("groceri") || q.contains("dining") || q.contains("eating") {
            return "You've spent **NOK 1 191** on groceries this month across Rema 1000, Kiwi, Meny, and Coop Extra. That's about NOK 298/week — slightly above the Norwegian average. Switching one shop per week to Kiwi or Rema could save ~NOK 150/month."
        }
        if q.contains("summar") || q.contains("overview") || q.contains("how am i") || q.contains("finances") {
            return "Your finances look solid overall.\n\n**Income**: NOK 34 250/month\n**Spending**: NOK 25 700/month\n**Left over**: NOK 8 550\n\nYou're saving consistently via BSU. Main area to watch: daily expenses — you've had 5 grocery visits in the last two weeks."
        }
        return "Based on your accounts and transactions, you have **NOK 34 250** available with **NOK 8 550** left over after typical monthly spending. What would you like to know about your finances?"
    }
}
