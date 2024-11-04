//
//  City.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 30/10/2024.
//

import CoreLocation


struct City: Equatable {
    let id: Int32
    let name: String
    let location: CLLocationCoordinate2D
    let countryCode: String
    var favorite: Bool
    
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.id == rhs.id
    }
}
