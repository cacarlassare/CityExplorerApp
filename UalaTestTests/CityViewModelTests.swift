//
//  CityViewModelTests.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 03/11/2024.
//


import XCTest
@testable import UalaTest
import CoreLocation


class CityViewModelTests: XCTestCase {
    
    var viewModel: MockCityViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = MockCityViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func createMockCities() -> [City] {
        return [
            City(id: 1, name: "San Francisco", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), countryCode: "US", favorite: false),
            City(id: 2, name: "Los Angeles", location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), countryCode: "US", favorite: false),
            City(id: 3, name: "New York", location: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), countryCode: "US", favorite: false),
            City(id: 4, name: "São Paulo", location: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333), countryCode: "BR", favorite: false),
            City(id: 5, name: "München", location: CLLocationCoordinate2D(latitude: 48.1351, longitude: 11.5820), countryCode: "DE", favorite: false),
            City(id: 6, name: "Kraków", location: CLLocationCoordinate2D(latitude: 50.0647, longitude: 19.9450), countryCode: "PL", favorite: false),
            City(id: 7, name: "Los Gatos", location: CLLocationCoordinate2D(latitude: 37.2358, longitude: -121.9624), countryCode: "US", favorite: false),
            City(id: 8, name: "York", location: CLLocationCoordinate2D(latitude: 53.959965, longitude: -1.087298), countryCode: "GB", favorite: false),
            City(id: 9, name: "Yorktown", location: CLLocationCoordinate2D(latitude: 37.2388, longitude: -76.5097), countryCode: "US", favorite: false),
            City(id: 10, name: "São José", location: CLLocationCoordinate2D(latitude: -33.4955, longitude: -70.7572), countryCode: "CL", favorite: false)
        ]
    }
    
    
    // MARK: - Tests
    
    func testFetchCitiesSuccess() {
        let expectation = self.expectation(description: "Fetch cities success")
        let mockCityResponses = createMockCities()
        viewModel.fetchCitiesResult = .success(mockCityResponses)
        
        viewModel.fetchCities { result in
            switch result {
            case .success(let cities):
                XCTAssertEqual(cities.count, 10)
                XCTAssertEqual(cities.first?.name, "San Francisco")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchCitiesFailure() {
        let expectation = self.expectation(description: "Fetch cities failure")
        let mockError = NetworkError.requestFailed(NSError(domain: "Test", code: -1, userInfo: nil))
        viewModel.fetchCitiesResult = .failure(mockError)
        
        viewModel.fetchCities { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, mockError.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFilterCities() {
        let cities = createMockCities()
        
        viewModel.fetchCitiesResult = .success(cities)
        viewModel.filteredCities = cities
        
        viewModel.filterCities(with: "San")
        
        XCTAssertEqual(viewModel.filteredCitiesCount, 1)
        XCTAssertEqual(viewModel.filteredCity(at: 0).name, "San Francisco")
    }
    
    func testToggleFavoriteSuccess() {
        let expectation = self.expectation(description: "Toggle favorite success")
        let city = City(id: 1, name: "San Francisco", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), countryCode: "US", favorite: false)
        
        viewModel.fetchCitiesResult = .success([city])
        viewModel.toggleFavoriteResult = .success(())
        
        viewModel.toggleFavorite(for: city) { result in
            switch result {
            case .success:
                XCTAssertTrue(true, "Expected toggleFavorite to succeed.")
            case .failure(let error):
                XCTFail("Expected toggleFavorite to succeed, but failed with error: \(error)")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testToggleFavoriteFailure() {
        let expectation = self.expectation(description: "Toggle favorite failure")
        let city = City(id: 1, name: "San Francisco", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), countryCode: "US", favorite: false)
        
        viewModel.fetchCitiesResult = .success([city])
        
        let mockError = CoreDataError.saveFailed(NSError(domain: "Test", code: -1, userInfo: nil))
        viewModel.toggleFavoriteResult = .failure(mockError)
        
        viewModel.toggleFavorite(for: city) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, mockError.localizedDescription)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    // MARK: Search Algorithm
    
    func testFilterCities_withCaseInsensitiveMatch() {
        let mockCityResponses = createMockCities()
        viewModel.fetchCitiesResult = .success(mockCityResponses)
        viewModel.filteredCities = mockCityResponses
        
        viewModel.filterCities(with: "los")
        
        XCTAssertEqual(viewModel.filteredCitiesCount, 2, "Expected 2 cities containing 'los' (case-insensitive)")
        let expectedCities = ["Los Angeles", "Los Gatos"]
        let filteredNames = (0..<viewModel.filteredCitiesCount).map { viewModel.filteredCity(at: $0).name }
        XCTAssertTrue(filteredNames.allSatisfy { expectedCities.contains($0) }, "Filtered cities do not match expected cities")
    }

    func testFilterCities_withNoMatch() {
        let mockCityResponses = createMockCities()
        viewModel.fetchCitiesResult = .success(mockCityResponses)
        viewModel.filteredCities = mockCityResponses
        
        viewModel.filterCities(with: "Chicago")
        
        XCTAssertEqual(viewModel.filteredCitiesCount, 0, "Expected 0 cities containing 'Chicago'")
    }

    func testFilterCities_withSpecialCharacters() {
        let mockCityResponses = createMockCities()
        viewModel.fetchCitiesResult = .success(mockCityResponses)
        viewModel.filteredCities = mockCityResponses
        
        viewModel.filterCities(with: "São")
        
        XCTAssertEqual(viewModel.filteredCitiesCount, 2, "Expected 2 cities containing 'São'")
        let expectedCities = ["São Paulo", "São José"]
        let filteredNames = (0..<viewModel.filteredCitiesCount).map { viewModel.filteredCity(at: $0).name }
        XCTAssertTrue(filteredNames.allSatisfy { expectedCities.contains($0) }, "Filtered cities do not match expected cities")
    }

    func testFilterCities_withWhitespace() {
        let mockCityResponses = createMockCities()
        viewModel.fetchCitiesResult = .success(mockCityResponses)
        viewModel.filteredCities = mockCityResponses
        
        viewModel.filterCities(with: " ")
        
        XCTAssertEqual(viewModel.filteredCitiesCount, 6, "Expected 2 cities containing a space in their name")
        let expectedCities = ["San Francisco", "Los Angeles", "Los Gatos", "New York", "São Paulo", "São José"]
        let filteredNames = (0..<viewModel.filteredCitiesCount).map { viewModel.filteredCity(at: $0).name }
        XCTAssertTrue(filteredNames.allSatisfy { expectedCities.contains($0) }, "Filtered cities do not match expected cities")
    }

    func testFilterCities_withPartialAndFullMatch() {
        let mockCityResponses = createMockCities()
        viewModel.fetchCitiesResult = .success(mockCityResponses)
        viewModel.filteredCities = mockCityResponses
        
        viewModel.filterCities(with: "York")
        
        XCTAssertEqual(viewModel.filteredCitiesCount, 3, "Expected 3 cities containing 'York'")
        let expectedCities = ["New York", "York", "Yorktown"]
        let filteredNames = (0..<viewModel.filteredCitiesCount).map { viewModel.filteredCity(at: $0).name }
        XCTAssertTrue(filteredNames.allSatisfy { expectedCities.contains($0) }, "Filtered cities do not match expected cities")
    }
}


class MockCityViewModel: CityViewModelProtocol {
    
    var fetchCitiesResult: Result<[City], Error>?
    var toggleFavoriteResult: Result<Void, Error>?
    var filteredCities: [City] = []
    
    func fetchCities(completion: @escaping (Result<[City], Error>) -> Void) {
        if let result = fetchCitiesResult {
            completion(result)
        }
    }
    
    func toggleFavorite(for city: City, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = toggleFavoriteResult {
            completion(result)
        }
    }
    
    var filteredCitiesCount: Int {
        return filteredCities.count
    }
    
    func filteredCity(at index: Int) -> City {
        return filteredCities[index]
    }
    
    func filterCities(with searchText: String) {
        let lowercasedText = searchText.lowercased()
        filteredCities = filteredCities.filter { $0.name.lowercased().contains(lowercasedText) }
    }
}
