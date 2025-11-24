# Wave 8 Task: Scraper Monitoring (iOS)

## Context
Build a mobile monitoring interface for the data scraping infrastructure on iOS, allowing admins to check scraper health, view recent results, and manually trigger jobs from their iPhone.

## Objective
Create a lightweight admin monitoring interface for the scraper system with real-time status updates and basic management capabilities using SwiftUI.

## Architecture

### View Structure
```
Sources/Views/Admin/Scraper/
├── ScraperDashboardView.swift      // Main monitoring view
├── ScraperJobListView.swift        // List of all jobs
├── ScraperJobDetailView.swift      // Job details and results
├── LocationTargetsView.swift       // View location targets
└── Components/
    ├── ScraperStatusCard.swift     // Status summary card
    ├── JobRow.swift                // Individual job row
    └── StatusBadge.swift           // Status indicator
```

## Data Models

### Models
**File:** `Sources/Models/Scraper/ScraperModels.swift`

```swift
import Foundation

struct ScraperJob: Codable, Identifiable {
    let id: String
    let sourceType: String
    let locationId: String
    let targetUrl: String
    let scheduleCron: String
    let enabled: Bool
    let lastRunAt: Date?
    let nextRunAt: Date?
    let status: ScraperStatus
    let createdAt: Date
    let updatedAt: Date
}

enum ScraperStatus: String, Codable {
    case pending = "pending"
    case running = "running"
    case success = "success"
    case failed = "failed"

    var color: Color {
        switch self {
        case .pending: return .yellow
        case .running: return .blue
        case .success: return .green
        case .failed: return .red
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock"
        case .running: return "arrow.triangle.2.circlepath"
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
}

struct ScraperResult: Codable, Identifiable {
    let id: String
    let jobId: String
    let startedAt: Date
    let completedAt: Date?
    let status: ResultStatus
    let classesFound: Int
    let classesImported: Int
    let errorMessage: String?
    let metrics: [String: AnyCodable]?
}

enum ResultStatus: String, Codable {
    case success, partial, failed
}

struct LocationTarget: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let city: String
    let state: String
    let latitude: Double
    let longitude: Double
    let radiusKm: Double
    let priority: Int
    let enabled: Bool
}

struct ScraperStats: Codable {
    let activeJobs: Int
    let successRate: Double
    let classesScrapedToday: Int
    let failedJobs: Int
    let totalLocations: Int
}
```

### API Service
**File:** `Sources/Services/ScraperService.swift`

```swift
import Foundation

class ScraperService: ObservableObject {
    private let apiClient: APIClient

    @Published var jobs: [ScraperJob] = []
    @Published var stats: ScraperStats?
    @Published var locationTargets: [LocationTarget] = []
    @Published var isLoading = false
    @Published var error: String?

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Jobs

    func fetchJobs() async {
        await MainActor.run { isLoading = true }

        do {
            let jobs: [ScraperJob] = try await apiClient.get("/api/v1/scrapers")
            await MainActor.run {
                self.jobs = jobs
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func triggerJob(_ jobId: String) async throws -> ScraperResult {
        return try await apiClient.post("/api/v1/scrapers/\(jobId)/trigger")
    }

    func enableJob(_ jobId: String, enabled: Bool) async throws {
        let _: ScraperJob = try await apiClient.patch(
            "/api/v1/scrapers/\(jobId)",
            body: ["enabled": enabled]
        )
        await fetchJobs()
    }

    func fetchJobResults(_ jobId: String) async throws -> [ScraperResult] {
        return try await apiClient.get("/api/v1/scrapers/\(jobId)/results")
    }

    // MARK: - Stats

    func fetchStats() async {
        do {
            let stats: ScraperStats = try await apiClient.get("/api/v1/scrapers/stats")
            await MainActor.run {
                self.stats = stats
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }

    // MARK: - Locations

    func fetchLocationTargets() async {
        do {
            let locations: [LocationTarget] = try await apiClient.get("/api/v1/locations")
            await MainActor.run {
                self.locationTargets = locations
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
}
```

## UI Implementation

### 1. Scraper Dashboard View
**File:** `Sources/Views/Admin/Scraper/ScraperDashboardView.swift`

```swift
import SwiftUI

struct ScraperDashboardView: View {
    @StateObject private var service = ScraperService()
    @State private var showingJobList = false
    @State private var showingLocations = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Grid
                    if let stats = service.stats {
                        StatsGridView(stats: stats)
                    }

                    // Quick Actions
                    QuickActionsView(
                        onViewJobs: { showingJobList = true },
                        onViewLocations: { showingLocations = true }
                    )

                    // Recent Jobs
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Job Runs")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(service.jobs.prefix(10)) { job in
                            JobRowView(
                                job: job,
                                onTrigger: {
                                    Task {
                                        try? await service.triggerJob(job.id)
                                        await service.fetchJobs()
                                    }
                                }
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Scraper Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await service.fetchStats()
                await service.fetchJobs()
            }
            .task {
                await service.fetchStats()
                await service.fetchJobs()
            }
            .sheet(isPresented: $showingJobList) {
                ScraperJobListView(service: service)
            }
            .sheet(isPresented: $showingLocations) {
                LocationTargetsView(service: service)
            }
        }
    }
}

struct StatsGridView: View {
    let stats: ScraperStats

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Active Jobs",
                value: "\(stats.activeJobs)",
                icon: "briefcase.fill",
                color: .blue
            )

            StatCard(
                title: "Success Rate",
                value: "\(Int(stats.successRate * 100))%",
                icon: "checkmark.circle.fill",
                color: .green
            )

            StatCard(
                title: "Classes Today",
                value: "\(stats.classesScrapedToday)",
                icon: "calendar",
                color: .purple
            )

            StatCard(
                title: "Failed",
                value: "\(stats.failedJobs)",
                icon: "exclamationmark.triangle.fill",
                color: stats.failedJobs > 0 ? .red : .gray
            )
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionsView: View {
    let onViewJobs: () -> Void
    let onViewLocations: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onViewJobs) {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                    Text("View All Jobs")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }

            Button(action: onViewLocations) {
                HStack {
                    Image(systemName: "map")
                    Text("View Locations")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}
```

### 2. Job Row Component
**File:** `Sources/Views/Admin/Scraper/Components/JobRowView.swift`

```swift
import SwiftUI

struct JobRowView: View {
    let job: ScraperJob
    let onTrigger: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    StatusBadgeView(status: job.status)

                    Text(job.sourceType)
                        .font(.headline)
                }

                if let lastRun = job.lastRunAt {
                    Text("Last run: \(lastRun, style: .relative) ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Never run")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !job.enabled {
                    Text("Disabled")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            Button(action: onTrigger) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct StatusBadgeView: View {
    let status: ScraperStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption)

            Text(status.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.2))
        .foregroundColor(status.color)
        .cornerRadius(6)
    }
}
```

### 3. Job List View
**File:** `Sources/Views/Admin/Scraper/ScraperJobListView.swift`

```swift
import SwiftUI

struct ScraperJobListView: View {
    @ObservedObject var service: ScraperService
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(service.jobs) { job in
                    JobRowView(
                        job: job,
                        onTrigger: {
                            Task {
                                try? await service.triggerJob(job.id)
                                await service.fetchJobs()
                            }
                        }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(job.enabled ? "Disable" : "Enable") {
                            Task {
                                try? await service.enableJob(job.id, enabled: !job.enabled)
                            }
                        }
                        .tint(job.enabled ? .orange : .green)
                    }
                }
            }
            .navigationTitle("All Jobs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .refreshable {
                await service.fetchJobs()
            }
        }
    }
}
```

### 4. Location Targets View
**File:** `Sources/Views/Admin/Scraper/LocationTargetsView.swift`

```swift
import SwiftUI
import MapKit

struct LocationTargetsView: View {
    @ObservedObject var service: ScraperService
    @Environment(\.dismiss) var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $region, annotationItems: service.locationTargets) { location in
                    MapMarker(
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude
                        ),
                        tint: location.enabled ? .green : .gray
                    )
                }
                .frame(height: 300)

                List(service.locationTargets) { location in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.headline)

                        Text("\(location.city), \(location.state)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Radius: \(location.radiusKm, specifier: "%.1f") km")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Location Targets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await service.fetchLocationTargets()
            }
        }
    }
}
```

## Navigation Integration

Add to admin menu in `AdminView.swift`:

```swift
NavigationLink(destination: ScraperDashboardView()) {
    Label("Scraper Monitoring", systemImage: "cloud.fill")
}
```

## Completion Criteria

- [ ] Scraper dashboard view with stats cards
- [ ] Job list view with status indicators
- [ ] Manual trigger functionality
- [ ] Enable/disable job swipe actions
- [ ] Location targets view with map
- [ ] Status badges with colors and icons
- [ ] Pull-to-refresh support
- [ ] Error handling and loading states
- [ ] Navigation integration

## Completion Marker

Create file `.task-scraper-monitoring-completed` when done.

---

**Agent Instructions**: Keep the UI clean and native iOS. Use SwiftUI best practices with async/await for API calls. Focus on clear status visualization and easy access to trigger buttons. The map view for locations is important but should be simple - just markers showing enabled/disabled locations.
