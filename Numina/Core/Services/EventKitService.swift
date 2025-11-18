//
//  EventKitService.swift
//  Numina
//
//  Service for iOS Calendar integration using EventKit
//

import Foundation
import EventKit

final class EventKitService {
    static let shared = EventKitService()

    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Authorization

    func requestCalendarAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            let status = try await eventStore.requestFullAccessToEvents()
            return status
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }

    func checkCalendarAuthorizationStatus() -> EKAuthorizationStatus {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .event)
        } else {
            return EKEventStore.authorizationStatus(for: .event)
        }
    }

    // MARK: - Export Booking to Calendar

    func addBookingToCalendar(_ booking: Booking) throws -> String {
        // Check authorization
        let status = checkCalendarAuthorizationStatus()
        guard status == .authorized || status == .fullAccess else {
            throw EventKitError.notAuthorized
        }

        // Create event
        let event = EKEvent(eventStore: eventStore)
        event.title = booking.className
        event.startDate = booking.startTime
        event.endDate = booking.endTime
        event.location = "\(booking.locationName), \(booking.locationAddress)"
        event.notes = """
        Class Type: \(booking.classType)
        Trainer: \(booking.trainerName)
        Duration: \(booking.duration) minutes

        Booked via Numina
        """

        // Set calendar (use default)
        event.calendar = eventStore.defaultCalendarForNewEvents

        // Add alarm if reminder is enabled
        if booking.reminderEnabled, let reminderMinutes = booking.reminderTime {
            let alarm = EKAlarm(relativeOffset: -TimeInterval(reminderMinutes * 60))
            event.addAlarm(alarm)
        }

        // Save event
        try eventStore.save(event, span: .thisEvent)

        return event.eventIdentifier
    }

    func addMultipleBookingsToCalendar(_ bookings: [Booking]) throws -> [String: String] {
        var eventIdentifiers: [String: String] = [:]

        for booking in bookings {
            do {
                let eventId = try addBookingToCalendar(booking)
                eventIdentifiers[booking.id] = eventId
            } catch {
                print("Failed to add booking \(booking.id) to calendar: \(error)")
                // Continue with other bookings
            }
        }

        return eventIdentifiers
    }

    // MARK: - Remove from Calendar

    func removeEventFromCalendar(eventIdentifier: String) throws {
        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
            throw EventKitError.eventNotFound
        }

        try eventStore.remove(event, span: .thisEvent)
    }

    // MARK: - Update Event

    func updateCalendarEvent(eventIdentifier: String, with booking: Booking) throws {
        guard let event = eventStore.event(withIdentifier: eventIdentifier) else {
            throw EventKitError.eventNotFound
        }

        event.title = booking.className
        event.startDate = booking.startTime
        event.endDate = booking.endTime
        event.location = "\(booking.locationName), \(booking.locationAddress)"
        event.notes = """
        Class Type: \(booking.classType)
        Trainer: \(booking.trainerName)
        Duration: \(booking.duration) minutes

        Booked via Numina
        """

        // Update alarms
        event.alarms?.forEach { event.removeAlarm($0) }

        if booking.reminderEnabled, let reminderMinutes = booking.reminderTime {
            let alarm = EKAlarm(relativeOffset: -TimeInterval(reminderMinutes * 60))
            event.addAlarm(alarm)
        }

        try eventStore.save(event, span: .thisEvent)
    }

    // MARK: - Check if Event Exists

    func eventExists(eventIdentifier: String) -> Bool {
        return eventStore.event(withIdentifier: eventIdentifier) != nil
    }

    // MARK: - Import from ICS

    func importFromICSData(_ icsData: String) throws -> [EKEvent] {
        // This is a simplified implementation
        // In a real app, you'd want to use a proper ICS parser

        var events: [EKEvent] = []

        // Split by VEVENT blocks
        let components = icsData.components(separatedBy: "BEGIN:VEVENT")

        for component in components.dropFirst() {
            guard let endIndex = component.range(of: "END:VEVENT")?.lowerBound else {
                continue
            }

            let eventData = String(component[..<endIndex])

            // Parse event (simplified)
            let event = EKEvent(eventStore: eventStore)
            event.calendar = eventStore.defaultCalendarForNewEvents

            // Extract title
            if let titleRange = eventData.range(of: "SUMMARY:") {
                let titleStart = titleRange.upperBound
                if let titleEnd = eventData[titleStart...].range(of: "\n")?.lowerBound {
                    event.title = String(eventData[titleStart..<titleEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }

            // Save event
            try eventStore.save(event, span: .thisEvent)
            events.append(event)
        }

        return events
    }
}

// MARK: - Errors

enum EventKitError: LocalizedError {
    case notAuthorized
    case eventNotFound
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Calendar access not authorized. Please grant permission in Settings."
        case .eventNotFound:
            return "Calendar event not found."
        case .saveFailed:
            return "Failed to save event to calendar."
        }
    }
}
