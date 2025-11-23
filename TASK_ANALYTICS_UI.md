# Task: Add Analytics & Insights UI

> **IMPORTANT**: Check for `.task-analytics-ui-completed` before starting.
> If it exists, respond: "✅ This task has already been implemented."
> **When finished**, create `.task-analytics-ui-completed` file.

## Overview
Add analytics and insights UI showing user activity, class trends, and personal fitness journey visualization using SwiftUI and Charts framework.

## Requirements

### 1. Data Models

**File**: `Numina/Models/Analytics.swift`

```swift
import Foundation

struct UserInsights: Codable, Identifiable {
    let id = UUID()
    let userId: String
    let period: String
    let classesAttended: Int
    let favoriteClassTypes: [String]
    let streakDays: Int
    let totalPointsEarned: Int
    let topTrainers: [TrainerSummary]
    let activityTrend: [DayActivity]
}

struct TrainerSummary: Codable, Identifiable {
    let id = UUID()
    let trainerId: String
    let name: String
    let classesAttended: Int
}

struct DayActivity: Codable, Identifiable {
    let id = UUID()
    let date: String
    let classCount: Int
    let minutesActive: Int
}

enum AnalyticsPeriod: String, CaseIterable {
    case week = "week"
    case month = "month"
    case year = "year"

    var displayName: String {
        rawValue.capitalized
    }
}
```

### 2. API Service

**File**: `Numina/Services/AnalyticsService.swift`

```swift
import Foundation

class AnalyticsService {
    private let baseURL: String

    init(baseURL: String = "http://localhost:8080/api/v1") {
        self.baseURL = baseURL
    }

    func getUserInsights(period: AnalyticsPeriod) async throws -> UserInsights {
        guard let url = URL(string: "\(baseURL)/analytics/users/me?period=\(period.rawValue)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Add auth token from keychain
        if let token = KeychainHelper.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(UserInsights.self, from: data)
    }
}
```

### 3. Analytics Dashboard View

**File**: `Numina/Features/Analytics/AnalyticsDashboardView.swift`

```swift
import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedPeriod: AnalyticsPeriod = .week

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedPeriod) { newPeriod in
                        viewModel.loadInsights(period: newPeriod)
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if let insights = viewModel.insights {
                        // Summary cards
                        HStack(spacing: 12) {
                            SummaryCard(title: "Classes", value: "\(insights.classesAttended)")
                            SummaryCard(title: "Streak", value: "\(insights.streakDays) days")
                            SummaryCard(title: "Points", value: "\(insights.totalPointsEarned)")
                        }
                        .padding(.horizontal)

                        // Activity chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity Trend")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)

                            Chart(insights.activityTrend) { day in
                                BarMark(
                                    x: .value("Date", day.date),
                                    y: .value("Classes", day.classCount)
                                )
                                .foregroundStyle(.blue)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }

                        // Favorite class types
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Favorite Activities")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(insights.favoriteClassTypes, id: \.self) { type in
                                        Text(type)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Top trainers
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Trainers")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                ForEach(insights.topTrainers) { trainer in
                                    TrainerRow(trainer: trainer)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    } else if let error = viewModel.error {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Your Insights")
            .onAppear {
                viewModel.loadInsights(period: selectedPeriod)
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct TrainerRow: View {
    let trainer: TrainerSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(trainer.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text("\(trainer.classesAttended) classes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// ViewModel
class AnalyticsViewModel: ObservableObject {
    @Published var insights: UserInsights?
    @Published var isLoading = false
    @Published var error: String?

    private let service = AnalyticsService()

    func loadInsights(period: AnalyticsPeriod) {
        isLoading = true
        error = nil

        Task {
            do {
                let data = try await service.getUserInsights(period: period)
                await MainActor.run {
                    self.insights = data
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
```

### 4. Navigation Integration

Add to main tab view or navigation:

```swift
NavigationLink("Analytics", destination: AnalyticsDashboardView())
```

Or as tab:
```swift
TabView {
    // ... other tabs
    AnalyticsDashboardView()
        .tabItem {
            Label("Insights", systemImage: "chart.bar")
        }
}
```

## Completion Checklist
- [ ] All data models created
- [ ] API service implemented
- [ ] Analytics dashboard view complete
- [ ] Period selector (week/month/year)
- [ ] Activity trend chart using Charts framework
- [ ] Summary cards
- [ ] Favorite class types display
- [ ] Top trainers list
- [ ] Navigation integrated
- [ ] `.task-analytics-ui-completed` file created

## Success Criteria
1. ✅ Users can view their activity insights
2. ✅ Period filtering works smoothly
3. ✅ Charts visualize data clearly
4. ✅ All SwiftUI best practices followed
5. ✅ Proper error handling and loading states
