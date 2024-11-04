//
//  ErrorHandlerTests.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 03/11/2024.
//


import XCTest
@testable import UalaTest


class ErrorHandlerTests: XCTestCase {

    var errorHandler: ErrorHandler!
    var mockViewController: MockViewController!

    override func setUp() {
        super.setUp()
        errorHandler = ErrorHandler.shared
        mockViewController = MockViewController()
    }

    override func tearDown() {
        errorHandler = nil
        mockViewController = nil
        super.tearDown()
    }

    func testHandleNetworkError() {
        let networkError = NetworkError.noData
        let expectation = self.expectation(description: "Present UIAlertController")

        // Assign the expectation to the mock view controller
        mockViewController.presentExpectation = expectation

        errorHandler.handle(error: networkError, in: mockViewController)

        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(self.mockViewController.presentCalled, "Expected present to be called.")
            XCTAssertNotNil(self.mockViewController.presentedAlert, "Expected an alert to be presented.")
            XCTAssertEqual(self.mockViewController.presentedAlert?.title, "Error", "Alert title should be 'Error'.")
            XCTAssertEqual(self.mockViewController.presentedAlert?.message, networkError.localizedDescription, "Alert message should match the error description.")
        }
    }

    func testHandleCoreDataError() {
        let coreDataError = CoreDataError.saveFailed(NSError(domain: "Test", code: -1, userInfo: nil))
        let expectation = self.expectation(description: "Present UIAlertController")

        // Assign the expectation to the mock view controller
        mockViewController.presentExpectation = expectation

        errorHandler.handle(error: coreDataError, in: mockViewController)

        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(self.mockViewController.presentCalled, "Expected present to be called.")
            XCTAssertNotNil(self.mockViewController.presentedAlert, "Expected an alert to be presented.")
            XCTAssertEqual(self.mockViewController.presentedAlert?.title, "Error", "Alert title should be 'Error'.")
            XCTAssertEqual(self.mockViewController.presentedAlert?.message, "An error occurred while saving your data. Please try again.", "Alert message should match the error description.")
        }
    }

    func testHandleGeneralErrorWithRetry() {
        let generalError = GeneralError.unknownError
        let expectation = self.expectation(description: "Present UIAlertController")

        // Assign the expectation to the mock view controller
        mockViewController.presentExpectation = expectation

        errorHandler.handle(error: generalError, in: mockViewController, retryAction: {
            // Retry logic (can be left empty for this test)
        })

        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(self.mockViewController.presentCalled, "Expected present to be called.")
            XCTAssertNotNil(self.mockViewController.presentedAlert, "Expected an alert to be presented.")
            XCTAssertEqual(self.mockViewController.presentedAlert?.title, "Error", "Alert title should be 'Error'.")
            XCTAssertEqual(self.mockViewController.presentedAlert?.message, generalError.localizedDescription, "Alert message should match the error description.")

            // Additionally, check if the "Retry" and "OK" actions are present
            XCTAssertEqual(self.mockViewController.presentedAlert?.actions.count, 2, "Expected two actions: Retry and OK.")
            XCTAssertEqual(self.mockViewController.presentedAlert?.actions[0].title, "Retry", "First action should be 'Retry'.")
            XCTAssertEqual(self.mockViewController.presentedAlert?.actions[1].title, "OK", "Second action should be 'OK'.")
        }
    }
}



class MockViewController: UIViewController {
    var presentCalled = false
    var presentedAlert: UIAlertController?
    var presentExpectation: XCTestExpectation?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentCalled = true

        if let alert = viewControllerToPresent as? UIAlertController {
            presentedAlert = alert
        }

        // Fulfill the expectation if it's set
        presentExpectation?.fulfill()

        completion?()
    }
}
