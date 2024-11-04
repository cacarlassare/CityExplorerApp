//
//  ErrorHandler.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 03/11/2024.
//

import UIKit


class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    // Generalized error handling with retry option to keep the user experience consistent
    func handle(error: Error, in viewController: UIViewController, retryAction: (() -> Void)? = nil) {
        // Determine the appropriate message
        let message: String
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                message = networkError.localizedDescription
            case .requestFailed:
                message = "Unable to connect to the server. Please check your internet connection and try again."
            case .noData:
                message = "No data was received from the server."
            case .decodingError:
                message = "Received unexpected data from the server. Please try again later."
            case .unknownError:
                message = "An unknown network error occurred."
            }
            
        } else if let coreDataError = error as? CoreDataError {
            switch coreDataError {
            case .loadFailed:
                message = coreDataError.localizedDescription
            case .saveFailed:
                message = "An error occurred while saving your data. Please try again."
            case .fetchFailed:
                message = "An error occurred while fetching your data. Please try again."
            case .unknownError:
                message = "An unknown Core Data error occurred."
            }
        } else {
            // Handle other error types
            message = error.localizedDescription
        }
        
        // Create the alert
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        
        // If a retry action is provided, add a Retry button
        if let retry = retryAction {
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                retry()
            })
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        // Present the alert on the main thread
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
}


// General error for unknown states
enum GeneralError: Error, LocalizedError {
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
