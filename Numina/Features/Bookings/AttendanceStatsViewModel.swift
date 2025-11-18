//
//  AttendanceStatsViewModel.swift
//  Numina
//
//  ViewModel for attendance statistics and streaks
//

import Foundation
import SwiftData

@MainActor
final class AttendanceStatsViewModel: ObservableObject {
    @Published var stats: AttendanceStats?
    @Published var streak: StreakDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let bookingRepository: BookingRepository

    init(bookingRepository: BookingRepository) {
        self.bookingRepository = bookingRepository
    }

    // MARK: - Load Stats

    func loadStats(fromCache: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            stats = try await bookingRepository.getAttendanceStats(fromCache: fromCache)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadStreak() async {
        errorMessage = nil

        do {
            streak = try await bookingRepository.getStreak()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshStats() async {
        await loadStats(fromCache: false)
        await loadStreak()
    }

    // MARK: - Computed Properties

    var currentStreak: Int {
        streak?.currentStreak ?? stats?.currentStreak ?? 0
    }

    var longestStreak: Int {
        streak?.longestStreak ?? stats?.longestStreak ?? 0
    }

    var totalAttended: Int {
        stats?.totalAttended ?? 0
    }

    var totalCancelled: Int {
        stats?.totalCancelled ?? 0
    }

    var totalMissed: Int {
        stats?.totalMissed ?? 0
    }

    var totalClasses: Int {
        totalAttended + totalCancelled + totalMissed
    }

    var attendanceRate: Double {
        guard totalClasses > 0 else { return 0.0 }
        return Double(totalAttended) / Double(totalClasses) * 100
    }

    var classTypeBreakdown: [String: Int] {
        guard let stats = stats,
              let data = try? JSONDecoder().decode([String: Int].self, from: stats.classTypeBreakdown) else {
            return [:]
        }
        return data
    }

    var monthlyStats: [MonthlyStatDTO] {
        guard let stats = stats,
              let data = try? JSONDecoder().decode([MonthlyStatDTO].self, from: stats.monthlyStats) else {
            return []
        }
        return data
    }

    var topClassType: String? {
        let breakdown = classTypeBreakdown
        return breakdown.max(by: { $0.value < $1.value })?.key
    }

    var achievements: [Achievement] {
        var achievements: [Achievement] = []

        // Streak achievements
        if currentStreak >= 7 {
            achievements.append(Achievement(
                title: "Week Warrior",
                description: "7 day streak!",
                icon: "flame.fill",
                color: "orange"
            ))
        }

        if currentStreak >= 30 {
            achievements.append(Achievement(
                title: "Monthly Master",
                description: "30 day streak!",
                icon: "star.fill",
                color: "yellow"
            ))
        }

        if currentStreak >= 100 {
            achievements.append(Achievement(
                title: "Century Champion",
                description: "100 day streak!",
                icon: "crown.fill",
                color: "purple"
            ))
        }

        // Attendance achievements
        if totalAttended >= 10 {
            achievements.append(Achievement(
                title: "Getting Started",
                description: "10 classes attended",
                icon: "checkmark.circle.fill",
                color: "green"
            ))
        }

        if totalAttended >= 50 {
            achievements.append(Achievement(
                title: "Dedicated",
                description: "50 classes attended",
                icon: "checkmark.circle.fill",
                color: "blue"
            ))
        }

        if totalAttended >= 100 {
            achievements.append(Achievement(
                title: "Fitness Pro",
                description: "100 classes attended",
                icon: "trophy.fill",
                color: "gold"
            ))
        }

        // Attendance rate achievement
        if attendanceRate >= 90 && totalClasses >= 10 {
            achievements.append(Achievement(
                title: "Consistent",
                description: "90%+ attendance rate",
                icon: "chart.line.uptrend.xyaxis",
                color: "cyan"
            ))
        }

        return achievements
    }
}

// MARK: - Achievement Model

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: String
}
