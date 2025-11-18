//
//  AttendanceStatsView.swift
//  Numina
//
//  Stats and achievements view
//

import SwiftUI
import Charts

struct AttendanceStatsView: View {
    @StateObject var viewModel: AttendanceStatsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Streak Widget
                if viewModel.currentStreak > 0 || viewModel.totalAttended > 0 {
                    StreakWidget(
                        currentStreak: viewModel.currentStreak,
                        longestStreak: viewModel.longestStreak,
                        totalAttended: viewModel.totalAttended
                    )
                    .padding(.horizontal)
                }

                // Overall Stats
                statsOverview

                // Class Type Breakdown
                if !viewModel.classTypeBreakdown.isEmpty {
                    classTypeBreakdownSection
                }

                // Monthly Stats Chart
                if !viewModel.monthlyStats.isEmpty {
                    monthlyStatsSection
                }

                // Achievements
                if !viewModel.achievements.isEmpty {
                    achievementsSection
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Your Stats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.refreshStats()
        }
    }

    private var statsOverview: some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(
                    title: "Attended",
                    value: "\(viewModel.totalAttended)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "Cancelled",
                    value: "\(viewModel.totalCancelled)",
                    icon: "xmark.circle.fill",
                    color: .red
                )

                StatCard(
                    title: "Missed",
                    value: "\(viewModel.totalMissed)",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )

                StatCard(
                    title: "Attendance Rate",
                    value: String(format: "%.0f%%", viewModel.attendanceRate),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
            }
            .padding(.horizontal)
        }
    }

    private var classTypeBreakdownSection: some View {
        VStack(spacing: 16) {
            Text("Class Types")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(Array(viewModel.classTypeBreakdown.sorted(by: { $0.value > $1.value })), id: \.key) { type, count in
                    ClassTypeRow(classType: type, count: count, total: viewModel.totalAttended)
                }
            }
            .padding(.horizontal)
        }
    }

    private var monthlyStatsSection: some View {
        VStack(spacing: 16) {
            Text("Monthly Trend")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // Simple bar representation (iOS 15 compatible)
            VStack(spacing: 8) {
                ForEach(viewModel.monthlyStats.suffix(6), id: \.month) { stat in
                    MonthlyStatRow(stat: stat)
                }
            }
            .padding(.horizontal)
        }
    }

    private var achievementsSection: some View {
        VStack(spacing: 16) {
            Text("Achievements")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct ClassTypeRow: View {
    let classType: String
    let count: Int
    let total: Int

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(classType)
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text("\(count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))

                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MonthlyStatRow: View {
    let stat: MonthlyStatDTO

    var body: some View {
        HStack {
            Text(formattedMonth)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 24)

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: CGFloat(stat.attended) * 10)

                    Rectangle()
                        .fill(Color.red)
                        .frame(width: CGFloat(stat.cancelled) * 10)

                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: CGFloat(stat.missed) * 10)
                }
                .frame(height: 24)
            }
            .cornerRadius(4)

            Text("\(stat.attended + stat.cancelled + stat.missed)")
                .font(.caption.weight(.medium))
                .foregroundColor(.primary)
                .frame(width: 30)
        }
    }

    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        if let date = formatter.date(from: stat.month) {
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: date)
        }

        return stat.month
    }
}

struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 32))
                .foregroundColor(colorForAchievement)

            Text(achievement.title)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var colorForAchievement: Color {
        switch achievement.color {
        case "orange": return .orange
        case "yellow": return .yellow
        case "purple": return .purple
        case "green": return .green
        case "blue": return .blue
        case "cyan": return .cyan
        case "gold": return Color(red: 1.0, green: 0.84, blue: 0.0)
        default: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        AttendanceStatsView(viewModel: AttendanceStatsViewModel(bookingRepository: BookingRepository()))
    }
}
