//
//  CityViewModel.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 30/10/2024.
//

import CoreData
import CoreLocation


protocol CitySelectionDelegate: AnyObject {
    func didSelectCity(_ city: City)
}

protocol CityViewModelProtocol {
    func fetchCities(completion: @escaping (Result<[City], Error>) -> Void)
    func toggleFavorite(for city: City, completion: @escaping (Result<Void, Error>) -> Void)
    var filteredCitiesCount: Int { get }
    func filteredCity(at index: Int) -> City
    func filterCities(with searchText: String)
}


class CityViewModel: CityViewModelProtocol {
    
    
    // MARK: - Properties
    
    private let getCitiesURL = "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json" // Could move it into a Constants.URL struct if there were more URLs
    private let context = CoreDataManager.shared.context
    private var allCities: [City] = []
    private var filteredCities: [City] = []
    private let maxRetryCount = 3
    private let retryDelay: TimeInterval = 1.0 // Initial delay in seconds

    
    // MARK: - Public Methods

    func fetchCities(completion: @escaping (Result<[City], Error>) -> Void) {
        if allCities.isEmpty {
            // Attempt to load cities from Core Data for offline persistence
            allCities = fetchCitiesFromCoreData()
            
            if !allCities.isEmpty {
                filteredCities = allCities
                completion(.success(filteredCities))
                return
            }
        }
        
        // Use retry strategy for robust network fetch with exponential backoff to avoid server overload
        downloadCitiesWithRetry(retries: maxRetryCount, delay: retryDelay) { [weak self] result in
            switch result {
            case .success(let cities):
                self?.allCities = cities
                self?.filteredCities = cities
                completion(.success(cities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func filterCities(with searchText: String) {
        // Filters by city name
        if searchText.isEmpty {
            filteredCities = allCities
        } else {
            let lowercasedText = searchText.lowercased()
            filteredCities = allCities.filter { $0.name.lowercased().contains(lowercasedText) }
        }
    }
    
    var filteredCitiesCount: Int {
        return filteredCities.count
    }
    
    func filteredCity(at index: Int) -> City {
        return filteredCities[index]
    }
    
    func toggleFavorite(for city: City, completion: @escaping (Result<Void, Error>) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(.failure(GeneralError.unknownError))
                return
            }
            
            let predicate = NSPredicate(format: "id == %d", city.id)
            let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
            request.predicate = predicate
            
            do {
                let cityEntities = try self.context.fetch(request)
                if let cityEntity = cityEntities.first {
                    cityEntity.favorite.toggle()
                    try self.context.save()
                    
                    // Synchronize with Core Data to ensure data consistency
                    if let index = self.allCities.firstIndex(where: { $0.id == city.id }) {
                        self.allCities[index].favorite = cityEntity.favorite
                    }
                    
                    if let filteredIndex = self.filteredCities.firstIndex(where: { $0.id == city.id }) {
                        self.filteredCities[filteredIndex].favorite = cityEntity.favorite
                    }
                    
                    completion(.success(()))
                } else {
                    throw CoreDataError.fetchFailed(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "City not found in database."]))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - Private Helper Methods
    
    private func fetchCitiesFromCoreData() -> [City] {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        
        do {
            let cityEntities = try context.fetch(request)
            return cityEntities.map { cityEntity in
                City(
                    id: cityEntity.id,
                    name: cityEntity.name ?? "",
                    location: CLLocationCoordinate2D(latitude: cityEntity.latitude, longitude: cityEntity.longitude),
                    countryCode: cityEntity.country ?? "",
                    favorite: cityEntity.favorite
                )
            }.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } catch {
            return []
        }
    }
    
    private func downloadCitiesWithRetry(retries: Int, delay: TimeInterval, completion: @escaping (Result<[City], Error>) -> Void) {
        guard let url = URL(string: getCitiesURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        NetworkService.shared.fetch(from: url) { (result: Result<[CityResponse], Error>) in
            switch result {
            case .success(let cityResponses):
                var cities = cityResponses.map { $0.toCity() }
                cities = cities.sorted { $0.name.lowercased() < $1.name.lowercased() }
                
                self.saveCitiesToCoreData(cities: cities) { saveResult in
                    switch saveResult {
                    case .success():
                        completion(.success(cities))
                    case .failure(let saveError):
                        completion(.failure(saveError))
                    }
                }
            case .failure(let error):
                // Retries the request upon failure
                if retries > 0 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self.downloadCitiesWithRetry(retries: retries - 1, delay: delay * 2, completion: completion)
                    }
                } else {
                    completion(.failure(NetworkError.requestFailed(error)))
                }
            }
        }
    }
    
    private func saveCitiesToCoreData(cities: [City], completion: @escaping (Result<Void, CoreDataError>) -> Void) {
        // Inserts new city records into Core Data
        context.perform {
            do {
                for city in cities {
                    let cityEntity = CityEntity(context: self.context)
                    cityEntity.id = city.id
                    cityEntity.name = city.name
                    cityEntity.latitude = city.location.latitude
                    cityEntity.longitude = city.location.longitude
                    cityEntity.favorite = city.favorite
                    cityEntity.country = city.countryCode
                }
                try self.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(.saveFailed(error)))
            }
        }
    }
}
