import SwiftUI

struct ContentView: View {
    @StateObject private var mockData = MockData.shared
    @State private var selectedTab = 0

    let tabs: [(String, String)] = [
        ("house", "Home"),
        ("wallet.bifold", "Pay"),
        ("cylinder.split.1x2", "Spend"),
        ("banknote", "Save"),
        ("ellipsis", "More")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0: HomeView()
                case 1: PaymentsView()
                case 2: SpendingView()
                case 3: SavingsView()
                case 5: AIView()
                default: MoreView()
                }
            }
            .environmentObject(mockData)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)

            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    tabButton(icon: tab.0, label: tab.1, tag: index)
                }
                tabButton(icon: "sparkles", label: "AI", tag: 5)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func tabButton(icon: String, label: String, tag: Int) -> some View {
        Button(action: { selectedTab = tag }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == tag ? .medium : .light))
                    .foregroundColor(selectedTab == tag ? Color.dnbTeal : Color(.systemGray))
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(selectedTab == tag ? Color.dnbTeal : Color(.systemGray))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Group {
                    if selectedTab == tag {
                        Capsule().fill(Color(.systemGray5))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Design System
extension Color {
    static let dnbTeal = Color(hex: "#2e7d74")
    static let dnbLightTeal = Color(hex: "#e0f0ee")
    static let dnbNavy = Color(hex: "#163a38")
    static let dnbBackground = Color(hex: "#F2F2F2")
    static let dnbCardBackground = Color.white
}

// MARK: - Card Modifier
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.dnbCardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

#Preview {
    ContentView()
}
