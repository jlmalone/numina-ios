//
//  FitnessPreferencesStep.swift
//  Numina
//
//  Fitness preferences step in profile setup
//

import SwiftUI

struct FitnessPreferencesStep: View {
    @ObservedObject var viewModel: ProfileSetupViewModel

    let fitnessTypes = [
        "Yoga", "HIIT", "Spin", "Pilates", "Boxing", "Barre",
        "CrossFit", "Running", "Cycling", "Swimming", "Dance",
        "Strength Training", "Bootcamp", "Kickboxing", "Zumba"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("What types of fitness classes are you interested in?")
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(fitnessTypes, id: \.self) { type in
                        InterestButton(
                            title: type,
                            isSelected: viewModel.fitnessInterests.contains(type)
                        ) {
                            toggleInterest(type)
                        }
                    }
                }
                .padding(.horizontal)

                if !viewModel.fitnessInterests.isEmpty {
                    Text("Selected: \(viewModel.fitnessInterests.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(24)
        }
    }

    private func toggleInterest(_ interest: String) {
        if viewModel.fitnessInterests.contains(interest) {
            viewModel.fitnessInterests.remove(interest)
        } else {
            viewModel.fitnessInterests.insert(interest)
        }
    }
}

struct InterestButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ?
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    ).opacity(0.2) :
                    LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(isSelected ? .orange : .primary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                )
        }
    }
}

#Preview {
    FitnessPreferencesStep(viewModel: ProfileSetupViewModel(userRepository: UserRepository()))
}
