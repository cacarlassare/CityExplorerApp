//
//  NetworkError.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 03/11/2024.
//

import Foundation


enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)         // Underlying network error
    case noData
    case decodingError(Error)         // JSON decoding errors
    case unknownError
    
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .requestFailed(let error):
            return "Network request failed with error: \(error.localizedDescription)"
        case .noData:
            return "No data was received from the server."
        case .decodingError(let error):
            return "Failed to decode the data: \(error.localizedDescription)"
        case .unknownError:
            return "An unknown network error occurred."
        }
    }
}
