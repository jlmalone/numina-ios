//
//  User.swift
//  Numina
//
//  User data model
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: String
    var email: String
    var name: String
    var bio: String?
    var photoURL: String?
    var fitnessInterests: [String]
    var fitnessLevel: Int // 1-10
    var latitude: Double?
    var longitude: Double?
    var locationName: String?
    var availability: [AvailabilitySlot]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        email: String,
        name: String,
        bio: String? = nil,
        photoURL: String? = nil,
        fitnessInterests: [String] = [],
        fitnessLevel: Int = 5,
        latitude: Double? = nil,
        longitude: Double? = nil,
        locationName: String? = nil,
        availability: [AvailabilitySlot] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.bio = bio
        self.photoURL = photoURL
        self.fitnessInterests = fitnessInterests
        self.fitnessLevel = fitnessLevel
        self.latitude = latitude
        self.longitude = longitude
        self.locationName = locationName
        self.availability = availability
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Codable User DTO

struct UserDTO: Codable {
    let id: String
    let email: String
    let name: String
    let bio: String?
    let photoURL: String?
    let fitnessInterests: [String]
    let fitnessLevel: Int
    let latitude: Double?
    let longitude: Double?
    let locationName: String?
    let availability: [AvailabilitySlotDTO]
    let createdAt: Date
    let updatedAt: Date

    func toModel() -> User {
        User(
            id: id,
            email: email,
            name: name,
            bio: bio,
            photoURL: photoURL,
            fitnessInterests: fitnessInterests,
            fitnessLevel: fitnessLevel,
            latitude: latitude,
            longitude: longitude,
            locationName: locationName,
            availability: availability.map { $0.toModel() },
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension User {
    func toDTO() -> UserDTO {
        UserDTO(
            id: id,
            email: email,
            name: name,
            bio: bio,
            photoURL: photoURL,
            fitnessInterests: fitnessInterests,
            fitnessLevel: fitnessLevel,
            latitude: latitude,
            longitude: longitude,
            locationName: locationName,
            availability: availability.map { $0.toDTO() },
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Availability Slot

@Model
final class AvailabilitySlot {
    var dayOfWeek: Int // 0 = Sunday, 1 = Monday, etc.
    var startTime: String // HH:mm format
    var endTime: String // HH:mm format

    init(dayOfWeek: Int, startTime: String, endTime: String) {
        self.dayOfWeek = dayOfWeek
        self.startTime = startTime
        self.endTime = endTime
    }
}

struct AvailabilitySlotDTO: Codable {
    let dayOfWeek: Int
    let startTime: String
    let endTime: String

    func toModel() -> AvailabilitySlot {
        AvailabilitySlot(dayOfWeek: dayOfWeek, startTime: startTime, endTime: endTime)
    }
}

extension AvailabilitySlot {
    func toDTO() -> AvailabilitySlotDTO {
        AvailabilitySlotDTO(dayOfWeek: dayOfWeek, startTime: startTime, endTime: endTime)
    }

    var dayName: String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[dayOfWeek % 7]
    }
}

// MARK: - Auth Request/Response Models

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let refreshToken: String?
    let user: UserDTO
}

// MARK: - Profile Update Request

struct UpdateProfileRequest: Codable {
    let name: String?
    let bio: String?
    let photoURL: String?
    let fitnessInterests: [String]?
    let fitnessLevel: Int?
    let latitude: Double?
    let longitude: Double?
    let locationName: String?
    let availability: [AvailabilitySlotDTO]?
}
