//
//  CitySelectionViewController.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 30/10/2024.
//

import UIKit
import CoreLocation


class CitySelectionViewController: UIViewController {
    
    
    // MARK: - Properties
    
    var onCitySelected: ((City) -> Void)?
    private let viewModel: CityViewModelProtocol
    weak var delegate: CitySelectionDelegate?
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private var searchWorkItem: DispatchWorkItem?
    
    
    // MARK: - Initializer
    
    init(viewModel: CityViewModelProtocol = CityViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchBar()
        setupTableView()
        setupGestureRecognizers()
        fetchCities()
    }
    
    
    // MARK: - Setup Methods
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Select a City"
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for a city"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - Data Fetching
    
    private func fetchCities() {
        LoadingView.shared.show(in: self.view)
        
        viewModel.fetchCities { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                LoadingView.shared.hide()
                
                switch result {
                case .success(_):
                    self.tableView.reloadData()
                case .failure(let error):
                    // Handles network or data errors with a retry option in case of failure
                    ErrorHandler.shared.handle(error: error, in: self) {
                        self.fetchCities()
                    }
                }
            }
        }
    }

    
    // MARK: - UI Update Methods
    
    private func applyCurrentSearchFilter() {
        // Cancel previous search work item to reduce reload frequency and improve UI responsiveness
        searchWorkItem?.cancel()
        
        // Create a new search work item
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.viewModel.filterCities(with: self.searchBar.text ?? "")
            self.tableView.reloadData()
        }
        
        // Assign and execute the new work item after a delay
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    
    // MARK: - Deinitialization
    
    deinit {
        searchBar.delegate = nil
        tableView.delegate = nil
        tableView.dataSource = nil
    }
}


// MARK: - UITableViewDataSource

extension CitySelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.filteredCitiesCount
        return count == 0 ? 1 : count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Show default cell if no cities match the search criteria
        if viewModel.filteredCitiesCount == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "EmptyCell")
            cell.textLabel?.text = "No cities found"
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.identifier, for: indexPath) as? CityTableViewCell else {
            return UITableViewCell()
        }

        let city = viewModel.filteredCity(at: indexPath.row)
        cell.configure(with: city)
        cell.selectionStyle = .none

        cell.onFavoriteTapped = { [weak self] in
            self?.toggleFavorite(for: city)
        }

        cell.onInfoTapped = { [weak self] in
            self?.showCityInfo(city)
        }

        return cell
    }
}


// MARK: - UITableViewDelegate

extension CitySelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.filteredCitiesCount > 0 else { return }
        
        let selectedCity = viewModel.filteredCity(at: indexPath.row)
        onCitySelected?(selectedCity)
    }
}


// MARK: - UISearchBarDelegate

extension CitySelectionViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyCurrentSearchFilter()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


// MARK: - Favorite Management

extension CitySelectionViewController {

    private func toggleFavorite(for city: City) {
        LoadingView.shared.show(in: self.view)
        
        viewModel.toggleFavorite(for: city) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                LoadingView.shared.hide()
                switch result {
                case .success():
                    self.tableView.reloadData()
                case .failure(let error):
                    // Option to retry favorite toggle in case of failure
                    ErrorHandler.shared.handle(error: error, in: self) {
                        self.toggleFavorite(for: city)
                    }
                }
            }
        }
    }

    private func showCityInfo(_ city: City) {
        let infoVC = CityInfoViewController(city: city)
        navigationController?.pushViewController(infoVC, animated: true)
    }
}
