//
//  CityTests.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 03/11/2024.
//

import XCTest
import CoreLocation
@testable import UalaTest


class CityTests: XCTestCase {
    
    func testCityInitialization() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let city = City(id: 1, name: "San Francisco", location: coordinate, countryCode: "US", favorite: false)
        
        XCTAssertEqual(city.id, 1)
        XCTAssertEqual(city.name, "San Francisco")
        XCTAssertEqual(city.location.latitude, 37.7749)
        XCTAssertEqual(city.location.longitude, -122.4194)
        XCTAssertEqual(city.countryCode, "US")
        XCTAssertFalse(city.favorite)
    }
    
    func testCityEquatable() {
        let coordinate1 = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let city1 = City(id: 1, name: "San Francisco", location: coordinate1, countryCode: "US", favorite: false)
        let city2 = City(id: 1, name: "San Francisco", location: coordinate1, countryCode: "US", favorite: true)
        let city3 = City(id: 2, name: "Los Angeles", location: coordinate1, countryCode: "US", favorite: false)
        
        XCTAssertEqual(city1, city2, "Cities with the same ID should be equal.")
        XCTAssertNotEqual(city1, city3, "Cities with different IDs should not be equal.")
    }
}
