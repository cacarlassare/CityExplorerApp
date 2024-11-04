//
//  CoreDataError.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 03/11/2024.
//

import Foundation


enum CoreDataError: Error, LocalizedError {
    case loadFailed(Error)             // Errors during Core Data stack loading
    case saveFailed(Error)             // Errors during save operations
    case fetchFailed(Error)            // Errors during fetch operations
    case unknownError

    var errorDescription: String? {
        switch self {
        case .loadFailed(let error):
            return "Failed to load Core Data stack: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .unknownError:
            return "An unknown Core Data error occurred."
        }
    }
}
