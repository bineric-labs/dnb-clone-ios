import Foundation

// Simple on-device linear regression: predicts end-of-month cumulative spend
// from (dayOfMonth, dailyAvgRate). No external frameworks needed.
class SpendingPredictor: ObservableObject {
    @Published var forecastPoints: [(day: Int, amount: Double)] = []
    @Published var isReady = false
    private(set) var predictedEndOfMonth: Double = 0

    func train(currentDaySpend: [(day: Int, cumulative: Double)]) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }

            // Derive daily average rate from actual data points that have spend
            let nonZero = currentDaySpend.filter { $0.cumulative > 0 }
            guard let first = nonZero.first, let last = nonZero.last, last.day > first.day else {
                return
            }
            let dailyRate = (last.cumulative - first.cumulative) / Double(last.day - first.day)
            let lastDay = last.day
            let lastAmount = last.cumulative

            // Project forward day-by-day, slight deceleration toward month end
            var forecast: [(day: Int, amount: Double)] = [(day: lastDay, amount: lastAmount)]
            for day in (lastDay + 1)...31 {
                let daysLeft = day - lastDay
                // Spending slows slightly in last week of month
                let decay: Double = day > 25 ? 0.75 : (day > 20 ? 0.88 : 1.0)
                let projected = lastAmount + dailyRate * decay * Double(daysLeft)
                forecast.append((day: day, amount: projected))
            }

            let eom = forecast.last?.amount ?? 0
            await MainActor.run {
                self.forecastPoints = forecast
                self.predictedEndOfMonth = eom
                self.isReady = true
            }
        }
    }
}
