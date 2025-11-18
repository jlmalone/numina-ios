//
//  FitnessLevelStep.swift
//  Numina
//
//  Fitness level step in profile setup
//

import SwiftUI

struct FitnessLevelStep: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    var body: some View {
        VStack(spacing: 32) {
            Text("What's your fitness level?")
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .padding(.top, 48)

            VStack(spacing: 16) {
                // Level Display
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.2), .red.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    VStack(spacing: 4) {
                        Text("\(Int(viewModel.fitnessLevel))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("/ 10")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }

                Text(levelDescription)
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            .padding(.vertical, 24)

            // Slider
            VStack(spacing: 12) {
                Slider(value: $viewModel.fitnessLevel, in: 1...10, step: 1)
                    .tint(.orange)

                HStack {
                    Text("Beginner")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Advanced")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding(24)
    }

    private var levelDescription: String {
        let level = Int(viewModel.fitnessLevel)
        switch level {
        case 1...2:
            return "Just Starting Out"
        case 3...4:
            return "Getting Active"
        case 5...6:
            return "Regular Exercise"
        case 7...8:
            return "Experienced"
        case 9...10:
            return "Advanced Athlete"
        default:
            return "Regular Exercise"
        }
    }
}

#Preview {
    FitnessLevelStep(viewModel: ProfileSetupViewModel(userRepository: UserRepository()))
}
