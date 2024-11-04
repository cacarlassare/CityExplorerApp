//
//  NetworkService.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 30/10/2024.
//

import Foundation


protocol URLSessionProtocol {
    func fetch<T: Decodable>(urlSession: URLSession, from url: URL, completion: @escaping (Result<T, Error>) -> Void)
}


class NetworkService: URLSessionProtocol {
    static let shared = NetworkService()
    
    private init() {}
    
    
    func fetch<T: Decodable>(urlSession: URLSession = URLSession.shared, from url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        let task = urlSession.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(NetworkError.requestFailed(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(NetworkError.decodingError(error)))
            }
        }
        
        task.resume()
    }
}
