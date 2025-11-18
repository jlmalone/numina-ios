//
//  ClassViewModelTests.swift
//  NuminaTests
//
//  Unit tests for ClassViewModel
//

import XCTest
@testable import Numina

@MainActor
final class ClassViewModelTests: XCTestCase {
    var viewModel: ClassViewModel!
    var mockRepository: MockClassRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockClassRepository()
        viewModel = ClassViewModel(classRepository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization_SetsDefaultValues() {
        XCTAssertTrue(viewModel.classes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.selectedClassType)
        XCTAssertEqual(viewModel.locationRadius, 10.0)
        XCTAssertFalse(viewModel.useCurrentLocation)
    }

    // MARK: - Load Classes Tests

    func testLoadClasses_Success_SetsClasses() async {
        let mockClasses = [
            FitnessClass.mockClass(id: "1", name: "Yoga"),
            FitnessClass.mockClass(id: "2", name: "HIIT")
        ]

        mockRepository.classesResult = .success(mockClasses)

        await viewModel.loadClasses()

        XCTAssertEqual(viewModel.classes.count, 2)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadClasses_Failure_SetsErrorMessage() async {
        mockRepository.classesResult = .failure(APIError.serverError(statusCode: 500, message: "Server error"))

        await viewModel.loadClasses()

        XCTAssertTrue(viewModel.classes.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Filter Tests

    func testClearFilters_ResetsAllFilters() {
        viewModel.startDate = Date()
        viewModel.endDate = Date()
        viewModel.selectedClassType = "Yoga"
        viewModel.minPrice = 10.0
        viewModel.maxPrice = 50.0
        viewModel.useCurrentLocation = true

        viewModel.clearFilters()

        XCTAssertNil(viewModel.startDate)
        XCTAssertNil(viewModel.endDate)
        XCTAssertNil(viewModel.selectedClassType)
        XCTAssertNil(viewModel.minPrice)
        XCTAssertNil(viewModel.maxPrice)
        XCTAssertFalse(viewModel.useCurrentLocation)
    }

    func testHasActiveFilters_WithNoFilters_ReturnsFalse() {
        XCTAssertFalse(viewModel.hasActiveFilters())
    }

    func testHasActiveFilters_WithDateFilter_ReturnsTrue() {
        viewModel.startDate = Date()
        XCTAssertTrue(viewModel.hasActiveFilters())
    }

    func testHasActiveFilters_WithClassTypeFilter_ReturnsTrue() {
        viewModel.selectedClassType = "Yoga"
        XCTAssertTrue(viewModel.hasActiveFilters())
    }

    func testHasActiveFilters_WithAllClassType_ReturnsFalse() {
        viewModel.selectedClassType = "All"
        XCTAssertFalse(viewModel.hasActiveFilters())
    }

    func testHasActiveFilters_WithPriceFilter_ReturnsTrue() {
        viewModel.minPrice = 10.0
        XCTAssertTrue(viewModel.hasActiveFilters())
    }

    func testHasActiveFilters_WithLocationFilter_ReturnsTrue() {
        viewModel.useCurrentLocation = true
        XCTAssertTrue(viewModel.hasActiveFilters())
    }

    // MARK: - Refresh Tests

    func testRefreshClasses_CallsLoadClasses() async {
        let mockClasses = [FitnessClass.mockClass(id: "1", name: "Yoga")]
        mockRepository.classesResult = .success(mockClasses)

        await viewModel.refreshClasses()

        XCTAssertEqual(viewModel.classes.count, 1)
        XCTAssertFalse(viewModel.isLoading)
    }
}

// MARK: - Mock Class Repository

class MockClassRepository: ClassRepository {
    var classesResult: Result<[FitnessClass], Error> = .failure(APIError.unknown)
    var classDetailsResult: Result<FitnessClass, Error> = .failure(APIError.unknown)

    override func getClasses(filters: ClassFilters?, fromCache: Bool) async throws -> [FitnessClass] {
        switch classesResult {
        case .success(let classes):
            return classes
        case .failure(let error):
            throw error
        }
    }

    override func getClassDetails(id: String, fromCache: Bool) async throws -> FitnessClass {
        switch classDetailsResult {
        case .success(let fitnessClass):
            return fitnessClass
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Mock Data Extensions

extension FitnessClass {
    static func mockClass(id: String, name: String) -> FitnessClass {
        FitnessClass(
            id: id,
            name: name,
            classDescription: "Test class description",
            classType: "Yoga",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            duration: 60,
            intensity: 5,
            price: 25.0,
            locationName: "Test Studio",
            locationAddress: "123 Test St",
            latitude: 37.7749,
            longitude: -122.4194,
            trainerName: "Test Trainer",
            provider: "TestPass",
            bookingURL: "https://test.com"
        )
    }
}
