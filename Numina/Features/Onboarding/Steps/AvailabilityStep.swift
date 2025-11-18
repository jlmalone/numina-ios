//
//  AvailabilityStep.swift
//  Numina
//
//  Availability step in profile setup
//

import SwiftUI

struct AvailabilityStep: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    @State private var showingAddSlot = false
    @State private var selectedDay = 0
    @State private var startTime = Date()
    @State private var endTime = Date()

    var body: some View {
        VStack(spacing: 24) {
            Text("When are you usually available?")
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text("Add your preferred workout times")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Availability List
            if viewModel.availability.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(.orange.opacity(0.5))

                    Text("No availability added yet")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.availability.enumerated()), id: \.offset) { index, slot in
                            AvailabilitySlotRow(slot: slot) {
                                viewModel.availability.remove(at: index)
                            }
                        }
                    }
                }
            }

            Spacer()

            // Add Button
            Button(action: {
                showingAddSlot = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Time Slot")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(12)
            }
        }
        .padding(24)
        .sheet(isPresented: $showingAddSlot) {
            AddAvailabilitySheet(
                selectedDay: $selectedDay,
                startTime: $startTime,
                endTime: $endTime,
                onSave: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"

                    let slot = AvailabilitySlot(
                        dayOfWeek: selectedDay,
                        startTime: formatter.string(from: startTime),
                        endTime: formatter.string(from: endTime)
                    )
                    viewModel.availability.append(slot)
                    showingAddSlot = false
                }
            )
        }
    }
}

struct AvailabilitySlotRow: View {
    let slot: AvailabilitySlot
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(slot.dayName)
                    .font(.headline)

                Text("\(slot.startTime) - \(slot.endTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AddAvailabilitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDay: Int
    @Binding var startTime: Date
    @Binding var endTime: Date
    let onSave: () -> Void

    let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Day of Week", selection: $selectedDay) {
                        ForEach(0..<days.count, id: \.self) { index in
                            Text(days[index]).tag(index)
                        }
                    }
                }

                Section {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)

                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Time Slot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AvailabilityStep(viewModel: ProfileSetupViewModel(userRepository: UserRepository()))
}
