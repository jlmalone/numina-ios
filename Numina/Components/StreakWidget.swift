//
//  StreakWidget.swift
//  Numina
//
//  Widget displaying current streak and stats
//

import SwiftUI

struct StreakWidget: View {
    let currentStreak: Int
    let longestStreak: Int
    let totalAttended: Int

    var body: some View {
        VStack(spacing: 16) {
            // Main Streak Display
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: streakGradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.orange.opacity(0.3), radius: 10)

                    VStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)

                        Text("\(currentStreak)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Text("Day Streak")
                    .font(.headline)
                    .foregroundColor(.primary)

                if currentStreak > 0 {
                    Text("Keep it going!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Stats Grid
            HStack(spacing: 20) {
                // Longest Streak
                VStack(spacing: 4) {
                    Text("\(longestStreak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)

                    Text("Longest")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 1)

                // Total Attended
                VStack(spacing: 4) {
                    Text("\(totalAttended)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)

                    Text("Attended")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var streakGradientColors: [Color] {
        if currentStreak == 0 {
            return [.gray, .gray.opacity(0.7)]
        } else if currentStreak >= 30 {
            return [.purple, .pink]
        } else if currentStreak >= 7 {
            return [.orange, .red]
        } else {
            return [.orange.opacity(0.8), .orange]
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakWidget(
            currentStreak: 15,
            longestStreak: 25,
            totalAttended: 87
        )

        StreakWidget(
            currentStreak: 0,
            longestStreak: 5,
            totalAttended: 12
        )
    }
    .padding()
}
