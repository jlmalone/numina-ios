//
//  FitnessClass.swift
//  Numina
//
//  Fitness class data model
//

import Foundation
import SwiftData

@Model
final class FitnessClass {
    @Attribute(.unique) var id: String
    var name: String
    var classDescription: String
    var classType: String // yoga, HIIT, spin, etc.
    var startTime: Date
    var endTime: Date
    var duration: Int // minutes
    var intensity: Int // 1-10
    var price: Double
    var currency: String
    var locationName: String
    var locationAddress: String
    var latitude: Double
    var longitude: Double
    var trainerName: String
    var trainerBio: String?
    var trainerPhotoURL: String?
    var provider: String // ClassPass, Mindbody, etc.
    var bookingURL: String
    var spotsAvailable: Int?
    var totalSpots: Int?
    var imageURL: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        name: String,
        classDescription: String,
        classType: String,
        startTime: Date,
        endTime: Date,
        duration: Int,
        intensity: Int,
        price: Double,
        currency: String = "USD",
        locationName: String,
        locationAddress: String,
        latitude: Double,
        longitude: Double,
        trainerName: String,
        trainerBio: String? = nil,
        trainerPhotoURL: String? = nil,
        provider: String,
        bookingURL: String,
        spotsAvailable: Int? = nil,
        totalSpots: Int? = nil,
        imageURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.classDescription = classDescription
        self.classType = classType
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.intensity = intensity
        self.price = price
        self.currency = currency
        self.locationName = locationName
        self.locationAddress = locationAddress
        self.latitude = latitude
        self.longitude = longitude
        self.trainerName = trainerName
        self.trainerBio = trainerBio
        self.trainerPhotoURL = trainerPhotoURL
        self.provider = provider
        self.bookingURL = bookingURL
        self.spotsAvailable = spotsAvailable
        self.totalSpots = totalSpots
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Codable DTO

struct FitnessClassDTO: Codable {
    let id: String
    let name: String
    let description: String
    let type: String
    let startTime: Date
    let endTime: Date
    let duration: Int
    let intensity: Int
    let price: Double
    let currency: String
    let location: LocationDTO
    let trainer: TrainerDTO
    let provider: String
    let bookingURL: String
    let spotsAvailable: Int?
    let totalSpots: Int?
    let imageURL: String?
    let createdAt: Date
    let updatedAt: Date

    func toModel() -> FitnessClass {
        FitnessClass(
            id: id,
            name: name,
            classDescription: description,
            classType: type,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            intensity: intensity,
            price: price,
            currency: currency,
            locationName: location.name,
            locationAddress: location.address,
            latitude: location.latitude,
            longitude: location.longitude,
            trainerName: trainer.name,
            trainerBio: trainer.bio,
            trainerPhotoURL: trainer.photoURL,
            provider: provider,
            bookingURL: bookingURL,
            spotsAvailable: spotsAvailable,
            totalSpots: totalSpots,
            imageURL: imageURL,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension FitnessClass {
    func toDTO() -> FitnessClassDTO {
        FitnessClassDTO(
            id: id,
            name: name,
            description: classDescription,
            type: classType,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            intensity: intensity,
            price: price,
            currency: currency,
            location: LocationDTO(
                name: locationName,
                address: locationAddress,
                latitude: latitude,
                longitude: longitude
            ),
            trainer: TrainerDTO(
                name: trainerName,
                bio: trainerBio,
                photoURL: trainerPhotoURL
            ),
            provider: provider,
            bookingURL: bookingURL,
            spotsAvailable: spotsAvailable,
            totalSpots: totalSpots,
            imageURL: imageURL,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: price)) ?? "\(price) \(currency)"
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

    var intensityDescription: String {
        switch intensity {
        case 1...3:
            return "Low"
        case 4...6:
            return "Moderate"
        case 7...9:
            return "High"
        case 10:
            return "Extreme"
        default:
            return "Unknown"
        }
    }
}

// MARK: - Supporting Models

struct LocationDTO: Codable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}

struct TrainerDTO: Codable {
    let name: String
    let bio: String?
    let photoURL: String?
}

// MARK: - Class List Response

struct ClassListResponse: Codable {
    let classes: [FitnessClassDTO]
    let total: Int
    let page: Int
    let limit: Int
}
