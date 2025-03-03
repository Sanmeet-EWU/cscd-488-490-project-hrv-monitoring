//
//  CloudManager.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import Foundation

class CloudManager {
    static let shared = CloudManager()
    
    // Define a single base URL for your API.
    private let baseURL = URL(string: "https://your-api-endpoint.example.com")!
    
    // Send HRV Data to the endpoint: baseURL/hrvData
    func sendHRVData(request: AddHRVDataRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let hrvEndpoint = baseURL.appendingPathComponent("hrvData")
        var urlRequest = URLRequest(url: hrvEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "CloudManager", code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
    
    // Send or update user data to the endpoint: baseURL/addUserData
    func addOrUpdateUser(userData: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        let userEndpoint = baseURL.appendingPathComponent("addUserData")
        var urlRequest = URLRequest(url: userEndpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(userData)
            urlRequest.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "CloudManager", code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
}
