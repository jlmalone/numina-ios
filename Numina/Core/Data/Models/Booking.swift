//
//  Booking.swift
//  Numina
//
//  Booking data model for calendar and attendance tracking
//

import Foundation
import SwiftData

@Model
final class Booking {
    @Attribute(.unique) var id: String
    var userId: String
    var classId: String
    var className: String
    var classType: String
    var startTime: Date
    var endTime: Date
    var duration: Int
    var locationName: String
    var locationAddress: String
    var trainerName: String
    var trainerPhotoURL: String?
    var status: String // "confirmed", "cancelled", "attended", "missed"
    var attended: Bool
    var attendedAt: Date?
    var reminderEnabled: Bool
    var reminderTime: Int? // minutes before class
    var imageURL: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        userId: String,
        classId: String,
        className: String,
        classType: String,
        startTime: Date,
        endTime: Date,
        duration: Int,
        locationName: String,
        locationAddress: String,
        trainerName: String,
        trainerPhotoURL: String? = nil,
        status: String = "confirmed",
        attended: Bool = false,
        attendedAt: Date? = nil,
        reminderEnabled: Bool = true,
        reminderTime: Int? = 60,
        imageURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.classId = classId
        self.className = className
        self.classType = classType
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.trainerName = trainerName
        self.trainerPhotoURL = trainerPhotoURL
        self.status = status
        self.attended = attended
        self.attendedAt = attendedAt
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Codable DTO

struct BookingDTO: Codable {
    let id: String
    let userId: String
    let classInfo: BookingClassInfoDTO
    let status: String
    let attended: Bool
    let attendedAt: Date?
    let reminderEnabled: Bool
    let reminderTime: Int?
    let createdAt: Date
    let updatedAt: Date

    func toModel() -> Booking {
        Booking(
            id: id,
            userId: userId,
            classId: classInfo.id,
            className: classInfo.name,
            classType: classInfo.type,
            startTime: classInfo.startTime,
            endTime: classInfo.endTime,
            duration: classInfo.duration,
            locationName: classInfo.location.name,
            locationAddress: classInfo.location.address,
            trainerName: classInfo.trainer.name,
            trainerPhotoURL: classInfo.trainer.photoURL,
            status: status,
            attended: attended,
            attendedAt: attendedAt,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime,
            imageURL: classInfo.imageURL,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Booking {
    func toDTO() -> BookingDTO {
        BookingDTO(
            id: id,
            userId: userId,
            classInfo: BookingClassInfoDTO(
                id: classId,
                name: className,
                type: classType,
                startTime: startTime,
                endTime: endTime,
                duration: duration,
                location: BookingLocationDTO(
                    name: locationName,
                    address: locationAddress
                ),
                trainer: BookingTrainerDTO(
                    name: trainerName,
                    photoURL: trainerPhotoURL
                ),
                imageURL: imageURL
            ),
            status: status,
            attended: attended,
            attendedAt: attendedAt,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let start = formatter.string(from: startTime)
        let end = formatter.string(from: endTime)
        return "\(start) - \(end)"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: startTime)
    }

    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }

    var isUpcoming: Bool {
        return startTime > Date()
    }

    var isPast: Bool {
        return endTime < Date()
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(startTime)
    }

    var statusColor: String {
        switch status {
        case "confirmed":
            return "blue"
        case "attended":
            return "green"
        case "cancelled":
            return "red"
        case "missed":
            return "orange"
        default:
            return "gray"
        }
    }

    var statusIcon: String {
        switch status {
        case "confirmed":
            return "checkmark.circle"
        case "attended":
            return "checkmark.circle.fill"
        case "cancelled":
            return "xmark.circle"
        case "missed":
            return "exclamationmark.triangle"
        default:
            return "circle"
        }
    }
}

// MARK: - Supporting Models

struct BookingClassInfoDTO: Codable {
    let id: String
    let name: String
    let type: String
    let startTime: Date
    let endTime: Date
    let duration: Int
    let location: BookingLocationDTO
    let trainer: BookingTrainerDTO
    let imageURL: String?
}

struct BookingLocationDTO: Codable {
    let name: String
    let address: String
}

struct BookingTrainerDTO: Codable {
    let name: String
    let photoURL: String?
}

// MARK: - API Response Models

struct BookingListResponse: Codable {
    let bookings: [BookingDTO]
    let total: Int
    let page: Int?
    let limit: Int?
}

struct CreateBookingRequest: Codable {
    let classId: String
    let reminderEnabled: Bool
    let reminderTime: Int?
}

struct UpdateBookingRequest: Codable {
    let reminderEnabled: Bool?
    let reminderTime: Int?
}

struct MarkAttendedResponse: Codable {
    let booking: BookingDTO
    let streakUpdated: Bool
    let newStreak: Int?
}

// MARK: - Reminder Preferences

@Model
final class ReminderPreferences {
    @Attribute(.unique) var id: String
    var userId: String
    var defaultEnabled: Bool
    var defaultReminderTime: Int // minutes before
    var oneHourEnabled: Bool
    var twentyFourHourEnabled: Bool
    var quietHoursEnabled: Bool
    var quietHoursStart: Date?
    var quietHoursEnd: Date?
    var updatedAt: Date

    init(
        id: String = "default",
        userId: String,
        defaultEnabled: Bool = true,
        defaultReminderTime: Int = 60,
        oneHourEnabled: Bool = true,
        twentyFourHourEnabled: Bool = false,
        quietHoursEnabled: Bool = false,
        quietHoursStart: Date? = nil,
        quietHoursEnd: Date? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.defaultEnabled = defaultEnabled
        self.defaultReminderTime = defaultReminderTime
        self.oneHourEnabled = oneHourEnabled
        self.twentyFourHourEnabled = twentyFourHourEnabled
        self.quietHoursEnabled = quietHoursEnabled
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
        self.updatedAt = updatedAt
    }
}

struct ReminderPreferencesDTO: Codable {
    let defaultEnabled: Bool
    let defaultReminderTime: Int
    let oneHourEnabled: Bool
    let twentyFourHourEnabled: Bool
    let quietHoursEnabled: Bool
    let quietHoursStart: Date?
    let quietHoursEnd: Date?

    func toModel(userId: String) -> ReminderPreferences {
        ReminderPreferences(
            userId: userId,
            defaultEnabled: defaultEnabled,
            defaultReminderTime: defaultReminderTime,
            oneHourEnabled: oneHourEnabled,
            twentyFourHourEnabled: twentyFourHourEnabled,
            quietHoursEnabled: quietHoursEnabled,
            quietHoursStart: quietHoursStart,
            quietHoursEnd: quietHoursEnd
        )
    }
}

extension ReminderPreferences {
    func toDTO() -> ReminderPreferencesDTO {
        ReminderPreferencesDTO(
            defaultEnabled: defaultEnabled,
            defaultReminderTime: defaultReminderTime,
            oneHourEnabled: oneHourEnabled,
            twentyFourHourEnabled: twentyFourHourEnabled,
            quietHoursEnabled: quietHoursEnabled,
            quietHoursStart: quietHoursStart,
            quietHoursEnd: quietHoursEnd
        )
    }
}

// MARK: - Stats Models

@Model
final class AttendanceStats {
    @Attribute(.unique) var id: String
    var userId: String
    var currentStreak: Int
    var longestStreak: Int
    var totalAttended: Int
    var totalCancelled: Int
    var totalMissed: Int
    var classTypeBreakdown: Data // Dictionary encoded as JSON
    var monthlyStats: Data // Array of monthly stats encoded as JSON
    var lastUpdated: Date

    init(
        id: String = "stats",
        userId: String,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalAttended: Int = 0,
        totalCancelled: Int = 0,
        totalMissed: Int = 0,
        classTypeBreakdown: Data = Data(),
        monthlyStats: Data = Data(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalAttended = totalAttended
        self.totalCancelled = totalCancelled
        self.totalMissed = totalMissed
        self.classTypeBreakdown = classTypeBreakdown
        self.monthlyStats = monthlyStats
        self.lastUpdated = lastUpdated
    }
}

struct AttendanceStatsDTO: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let totalAttended: Int
    let totalCancelled: Int
    let totalMissed: Int
    let classTypeBreakdown: [String: Int]
    let monthlyStats: [MonthlyStatDTO]

    func toModel(userId: String) -> AttendanceStats {
        let breakdownData = (try? JSONEncoder().encode(classTypeBreakdown)) ?? Data()
        let monthlyData = (try? JSONEncoder().encode(monthlyStats)) ?? Data()

        return AttendanceStats(
            userId: userId,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalAttended: totalAttended,
            totalCancelled: totalCancelled,
            totalMissed: totalMissed,
            classTypeBreakdown: breakdownData,
            monthlyStats: monthlyData
        )
    }
}

struct MonthlyStatDTO: Codable {
    let month: String // "2024-01"
    let attended: Int
    let cancelled: Int
    let missed: Int
}

struct StreakDTO: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let lastAttended: Date?
}

// MARK: - Calendar Models

struct CalendarMonthResponse: Codable {
    let month: String // "yyyy-MM"
    let bookings: [BookingDTO]
}

struct CalendarExportResponse: Codable {
    let icsData: String
    let bookingsCount: Int
}
