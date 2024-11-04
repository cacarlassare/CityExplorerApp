//
//  RootViewControllerTests.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 03/11/2024.
//

import XCTest
@testable import UalaTest
import CoreLocation


class RootViewControllerTests: XCTestCase {
    
    var rootViewController: RootViewController!
    
    
    override func setUp() {
        super.setUp()
        rootViewController = RootViewController()
        _ = rootViewController.view
    }
    
    override func tearDown() {
        rootViewController = nil
        super.tearDown()
    }
    
    
    // MARK: - Tests
    
    func testInitialViewHierarchySetup() {
        let rootViewController = RootViewController()
        let _ = MockNavigationController(rootViewController: rootViewController)
        
        rootViewController.viewDidLoad()
        
        let navigationController = rootViewController.navigationController
        let citySelectionVC = rootViewController.children.first as? CitySelectionViewController
        
        XCTAssertNotNil(navigationController, "RootViewController should have a UINavigationController as child")
        XCTAssertNotNil(citySelectionVC, "UINavigationController should have CitySelectionViewController as root")
    }

    func testNavigationToMapViewController() {
        let rootViewController = RootViewController()
        let mockNavigationController = MockNavigationController(rootViewController: rootViewController)
        
        let expectation = self.expectation(description: "MapViewController should be pushed")
        
        let city = City(id: 1, name: "San Francisco", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), countryCode: "US", favorite: false)
        rootViewController.showMap(for: city)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(mockNavigationController.pushedViewController is MapViewController, "Pushed view controller should be MapViewController")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}


class MockNavigationController: UINavigationController {
    
    var pushedViewController: UIViewController?
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: false)
    }
}
