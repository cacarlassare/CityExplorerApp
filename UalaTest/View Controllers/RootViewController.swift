//
//  RootViewController.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 30/10/2024.
//

import UIKit


class RootViewController: UIViewController, CoreDataManagerDelegate {
    
    
    // MARK: - Child View Controllers
    
    private let citySelectionVC: CitySelectionViewController = {
        let viewController = CitySelectionViewController()
        return viewController
    }()
    
    private let mapVC: MapViewController = {
        let viewController = MapViewController()
        return viewController
    }()
    
    private let landscapeMapVC: MapViewController = {
        let viewController = MapViewController()
        return viewController
    }()
    
    
    // MARK: - UI Components
    
    private var stackView: UIStackView?
    
    
    // MARK: - State Management
    
    private var isMapViewPresented: Bool {
        return navigationController?.topViewController === mapVC
    }
    
    private var isLandscape: Bool {
        return traitCollection.verticalSizeClass == .compact && UIDevice.current.orientation.isLandscape
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.delegate = self
        configureInitialView()
        setupCitySelectionCallback()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Reconfigure layout only if vertical size class has changed and map is not presented via navigation
        if previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass, !isMapViewPresented {
            configureInitialView()
        }
    }
    
    
    // MARK: - CoreDataManagerDelegate
    
    func coreDataManagerDidFailToLoad(error: CoreDataError) {
        ErrorHandler.shared.handle(error: error, in: self)
    }
    
    
    // MARK: - Setup Methods
    
    private func setupCitySelectionCallback() {
        citySelectionVC.onCitySelected = { [weak self] city in
            guard let self = self else { return }
            self.showMap(for: city)
        }
    }
    
    
    // MARK: - Configuration Methods
    
    private func configureInitialView() {
        removeAllChildViewControllers()
        view.subviews.forEach { $0.removeFromSuperview() }
        stackView = nil
        
        
        // Setup view based on orientation
        if isLandscape {
            setupLandscapeView()
        } else {
            setupPortraitView()
        }
    }
    
    private func removeAllChildViewControllers() {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    private func setupLandscapeView() {
        // Initialize stackView with citySelectionVC and landscapeMapVC
        stackView = UIStackView(arrangedSubviews: [citySelectionVC.view, landscapeMapVC.view])
        
        guard let stackView = stackView else { return }
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        view.addSubview(stackView)
        
        // Auto Layout
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add child view controllers
        addChild(citySelectionVC)
        addChild(landscapeMapVC)
        
        citySelectionVC.didMove(toParent: self)
        landscapeMapVC.didMove(toParent: self)
    }
    
    private func setupPortraitView() {
        addChild(citySelectionVC)
        view.addSubview(citySelectionVC.view)
        
        // Auto Layout
        citySelectionVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            citySelectionVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            citySelectionVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            citySelectionVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citySelectionVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        citySelectionVC.didMove(toParent: self)
    }
    
    
    // MARK: - Navigation Methods

    func showMap(for city: City?) {
        guard let city = city else {
            ErrorHandler.shared.handle(error: GeneralError.unknownError, in: self)
            return
        }
        
        DispatchQueue.main.async {
            if self.isLandscape {
                self.landscapeMapVC.updateMap(for: city)
            } else {
                self.mapVC.updateMap(for: city)
                self.navigationController?.pushViewController(self.mapVC, animated: true)
            }
        }
    }
}
