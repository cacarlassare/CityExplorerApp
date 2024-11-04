//
//  CityTableViewCell.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 31/10/2024.
//

import UIKit


class CityTableViewCell: UITableViewCell {

    static let identifier = "CityTableViewCell"

    
    // MARK: - Callbacks
    
    var onFavoriteTapped: (() -> Void)?
    var onInfoTapped: (() -> Void)?

    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemRed
        return button
    }()

    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    private let verticalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Setup Methods
    
    private func setupSubviews() {
        // Configure the favorite and info buttons
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)

        // Add labels to vertical stack
        verticalStack.addArrangedSubview(titleLabel)
        verticalStack.addArrangedSubview(subtitleLabel)

        // Create a stack for the favorite and info buttons
        let buttonStack = UIStackView(arrangedSubviews: [favoriteButton, infoButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10 // 10 pixels between heart and info button
        
        // Set up a horizontal stack for the main cell content
        let horizontalStack = UIStackView(arrangedSubviews: [verticalStack, buttonStack])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 8
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill

        contentView.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        
        // Add constraints
        NSLayoutConstraint.activate([
            buttonStack.widthAnchor.constraint(equalToConstant: 70),
            buttonStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    
    // MARK: - Action Methods
    
    @objc private func favoriteTapped() {
        onFavoriteTapped?()
    }

    @objc private func infoTapped() {
        onInfoTapped?()
    }

    
    // MARK: - Configuration Method
    
    func configure(with city: City) {
        titleLabel.text = "\(city.name), \(city.countryCode)"
        subtitleLabel.text = "Lat: \(city.location.latitude), Lon: \(city.location.longitude)"
        
        let heartImageName = city.favorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImageName), for: .normal)
    }
}
