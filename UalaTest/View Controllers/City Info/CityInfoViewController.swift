//
//  CityInfoViewController.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 31/10/2024.
//

import UIKit


class CityInfoViewController: UIViewController {

    
    // MARK: - Properties
    
    private let city: City
    

    // MARK: - Initializer
    
    init(city: City) {
        self.city = city
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCityInfo()
    }

    
    // MARK: - Setup Methods
    
    private func setupCityInfo() {
        let nameLabel = UILabel()
        nameLabel.text = "\(city.name), \(city.countryCode)"
        nameLabel.font = .boldSystemFont(ofSize: 25)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let coordinatesLabel = UILabel()
        coordinatesLabel.text = "Latitude: \(city.location.latitude), Longitude: \(city.location.longitude)"
        coordinatesLabel.font = .systemFont(ofSize: 18)
        coordinatesLabel.textColor = .gray
        coordinatesLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameLabel)
        view.addSubview(coordinatesLabel)

        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            coordinatesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coordinatesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10)
        ])
    }
}
