# DNB Clone iOS

A SwiftUI iOS banking app prototype inspired by [DNB](https://www.dnb.no) — Norway's largest bank. Built as a rapid prototyping demo to show how closely a modern banking UI can be replicated, and extended with two features that don't exist in the real app today: a **predictive spending forecast** and an **AI finance assistant**.

> ⚠️ This is an unofficial demo project with no affiliation to DNB ASA. Built for educational and portfolio purposes.

## Features

- **Home** — balance card, pending approvals, quick actions, accounts overview, currency converter
- **Payments** — eInvoice approval, transfer flow, scan QR action sheet
- **Spending** — category breakdown with animated bubble chart, budgets
- **Savings** — goals, fund returns, Spare integration
- **More** — profile, settings, full product menu
- **AI Assistant** — chat interface with spending context, suggestion cards, formatted markdown responses
- **Spending Forecast** — predictive chart based on transaction history

## Getting Started

1. Clone the repo
2. Open `DNBDemo.xcodeproj` in Xcode
3. Run on iPhone simulator (iOS 17+)

### Enable Real AI (optional)

The app works out of the box with built-in responses — no setup needed for demos.

To connect a live AI assistant:

1. Get an API key at [console.anthropic.com](https://console.anthropic.com)
2. Open `Config.xcconfig`
3. Add your key: `ANTHROPIC_API_KEY = sk-ant-...`
4. Rebuild

## Tech Stack

- SwiftUI (iOS 17+)
- Swift Charts
- No third-party dependencies

## Built by

Made by **Umair**, founder of [Bineric](https://bineric.no) — AI solutions for real businesses.

## License

MIT
