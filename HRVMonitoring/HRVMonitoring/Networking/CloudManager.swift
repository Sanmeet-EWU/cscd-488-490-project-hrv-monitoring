//
//  CloudManager.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import Foundation

class CloudManager {
    static let shared = CloudManager()
    
    // The base URL for your API. No additional resource path is appended.
    private let baseURL = URL(string: "https://s0pex2wkse.execute-api.us-west-1.amazonaws.com/FrontAndBackMerged")!
    
    // Send HRV Data using the baseURL directly.
    func sendHRVData(request: AddHRVDataRequest, completion: @escaping (Result<Int, Error>) -> Void) {
        var urlRequest = URLRequest(url: baseURL)
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
                print("🚨 Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔎 HTTP Status Code: \(httpResponse.statusCode)")
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📜 Response Body: \(responseString)")
                    
                    // Try to extract the numerical response code from the response body
                    if let responseInt = Int(responseString.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        print("🔢 Parsed Response Code: \(responseInt)")
                        completion(.success(responseInt))
                        return
                    }
                }
                
                // If the response is not 200-299, return an error
                if !(200..<300).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "CloudManager", code: httpResponse.statusCode,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                    completion(.failure(error))
                    return
                }
            }
            
            // Default error if we couldn't parse anything
            let unknownError = NSError(domain: "CloudManager", code: 0,
                                       userInfo: [NSLocalizedDescriptionKey: "Unknown response"])
            completion(.failure(unknownError))
        }.resume()
    }

    
    // Send or update user data using the baseURL directly.
    func addOrUpdateUser(userData: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        var urlRequest = URLRequest(url: baseURL)
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
            if let httpResponse = response as? HTTPURLResponse {
                print("🔎 HTTP Status Code: \(httpResponse.statusCode)")
                if !(200..<300).contains(httpResponse.statusCode) {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("🔎 Response Data: \(responseString)")
                    }
                    let error = NSError(domain: "CloudManager", code: httpResponse.statusCode,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                    completion(.failure(error))
                    return
                }
            }
            completion(.success(()))
        }.resume()
    }
    
    // Send questionnaire data using the baseURL directly.
    func sendQuestionnaireData(request: QuestionnaireRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        var urlRequest = URLRequest(url: baseURL)
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
            if let httpResponse = response as? HTTPURLResponse {
                print("🔎 HTTP Status Code: \(httpResponse.statusCode)")
                if !(200..<300).contains(httpResponse.statusCode) {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("🔎 Response Data: \(responseString)")
                    }
                    let error = NSError(domain: "CloudManager", code: httpResponse.statusCode,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                    completion(.failure(error))
                    return
                }
            }
            completion(.success(()))
        }.resume()
    }
}
