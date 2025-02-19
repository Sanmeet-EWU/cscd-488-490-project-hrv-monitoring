//
//  CloudManager.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import Foundation

class CloudManager {
    static let shared = CloudManager()
    
    // Update this URL to your AWS API endpoint.
    private let endpointURL = URL(string: "https://your-api-endpoint.example.com/")!
    
    func sendHRVData(request: AddHRVDataRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        var urlRequest = URLRequest(url: endpointURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        // You might use ISO8601 for dates, or another strategy as required.
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
                let error = NSError(domain: "CloudManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
}

