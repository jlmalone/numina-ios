//
//  WriteReviewViewModel.swift
//  Numina
//
//  ViewModel for writing reviews
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class WriteReviewViewModel: ObservableObject {
    @Published var rating: Int = 0
    @Published var reviewText: String = ""
    @Published var pros: [String] = []
    @Published var cons: [String] = []
    @Published var photoURLs: [String] = []
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // UI state
    @Published var newPro: String = ""
    @Published var newCon: String = ""

    private let reviewRepository: ReviewRepository
    private let classId: String

    var isValid: Bool {
        rating > 0 && !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(classId: String, reviewRepository: ReviewRepository) {
        self.classId = classId
        self.reviewRepository = reviewRepository
    }

    // MARK: - Pros/Cons Management

    func addPro() {
        let trimmed = newPro.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            pros.append(trimmed)
            newPro = ""
        }
    }

    func removePro(at index: Int) {
        guard index < pros.count else { return }
        pros.remove(at: index)
    }

    func addCon() {
        let trimmed = newCon.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            cons.append(trimmed)
            newCon = ""
        }
    }

    func removeCon(at index: Int) {
        guard index < cons.count else { return }
        cons.remove(at: index)
    }

    // MARK: - Photo Management

    func addPhotoURL(_ url: String) {
        photoURLs.append(url)
    }

    func removePhoto(at index: Int) {
        guard index < photoURLs.count else { return }
        photoURLs.remove(at: index)
    }

    // MARK: - Submit Review

    func submitReview() async -> Bool {
        guard isValid else {
            errorMessage = "Please provide a rating and review text"
            return false
        }

        isSubmitting = true
        errorMessage = nil

        do {
            _ = try await reviewRepository.createReview(
                classId: classId,
                rating: rating,
                reviewText: reviewText,
                pros: pros,
                cons: cons,
                photoURLs: photoURLs
            )

            successMessage = "Review submitted successfully!"
            isSubmitting = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            isSubmitting = false
            return false
        } catch {
            errorMessage = error.localizedDescription
            isSubmitting = false
            return false
        }
    }

    // MARK: - Draft Management

    func clearForm() {
        rating = 0
        reviewText = ""
        pros = []
        cons = []
        photoURLs = []
        newPro = ""
        newCon = ""
        errorMessage = nil
        successMessage = nil
    }
}
