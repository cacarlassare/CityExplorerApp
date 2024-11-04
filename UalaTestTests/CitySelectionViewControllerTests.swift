//
//  CitySelectionViewControllerTests.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 03/11/2024.
//

import XCTest
@testable import UalaTest
import UIKit
import CoreLocation


class CitySelectionViewControllerTests: XCTestCase {
    
    var viewController: CitySelectionViewController!
    var mockViewModel: MockCityViewModel!
    
    override func setUp() {
        super.setUp()
        mockViewModel = MockCityViewModel()
        viewController = CitySelectionViewController(viewModel: mockViewModel)
        _ = viewController.view
    }
    
    override func tearDown() {
        viewController = nil
        mockViewModel = nil
        super.tearDown()
    }
    
    func testFetchCitiesSuccess() {
        let expectation = self.expectation(description: "Fetch cities success")
        let cities = [
            City(id: 1, name: "San Francisco", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), countryCode: "US", favorite: false)
        ]
        mockViewModel.fetchCitiesResult = .success(cities)
        
        viewController.viewDidLoad()
        
        XCTAssertEqual(self.viewController.tableView(UITableView(), numberOfRowsInSection: 0), cities.count)
        expectation.fulfill()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchCitiesFailure() {
        let expectation = self.expectation(description: "Fetch cities failure")
        let mockError = NetworkError.requestFailed(NSError(domain: "Test", code: -1, userInfo: nil))
        mockViewModel.fetchCitiesResult = .failure(mockError)
        
        viewController.viewDidLoad()
        
        DispatchQueue.main.async {
            XCTAssertEqual(self.viewController.tableView(UITableView(), numberOfRowsInSection: 0), 1) // Empty state cell
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
