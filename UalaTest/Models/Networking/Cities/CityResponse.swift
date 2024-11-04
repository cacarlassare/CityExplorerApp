//
//  CityResponse.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 30/10/2024.
//

import CoreLocation


struct CityResponse: Decodable {
    let name: String
    let country: String
    let coord: Coordinate
    let id: Int32
    
    struct Coordinate: Decodable {
        let lon: Double
        let lat: Double
    }
    
    
    func toCity() -> City {
        return City(
            id: id,
            name: name,
            location: CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon),
            countryCode: country,
            favorite: false
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"       // Maps the JSON key "_id" to the property "id"
        case name
        case country
        case coord
    }
}
