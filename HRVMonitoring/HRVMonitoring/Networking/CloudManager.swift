//
//  CloudManager.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//
import Foundation
import os.log

class CloudManager {
    static let shared = CloudManager()
    
    // The base URL for your API. No additional resource path is appended.
    private let baseURL = URL(string: "https://s0pex2wkse.execute-api.us-west-1.amazonaws.com/FrontAndBackMerged")!
    
    // MARK: - Private Helper
    
    /// Performs a POST request with the given URLRequest and decodes the response using the ResponseFormat model.
    private func performPostRequest(with urlRequest: URLRequest,
                                    completion: @escaping (Result<ResponseFormat, Error>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                os_log("Network error: %@", log: OSLog.default, type: .error, error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let unknownError = NSError(domain: "CloudManager",
                                           code: 0,
                                           userInfo: [NSLocalizedDescriptionKey: "Unknown response"])
                completion(.failure(unknownError))
                return
            }
            
            os_log("HTTP Status Code: %d", log: OSLog.default, type: .info, httpResponse.statusCode)
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                if let data = data,
                   let responseString = String(data: data, encoding: .utf8) {
                    os_log("Response Data: %@", log: OSLog.default, type: .error, responseString)
                }
                let error = NSError(domain: "CloudManager",
                                    code: httpResponse.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "CloudManager",
                                    code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Empty response data"])
                completion(.failure(error))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                // Try decoding as a full JSON object first.
                let responseModel = try decoder.decode(ResponseFormat.self, from: data)
                os_log("Parsed Response: %@", log: OSLog.default, type: .debug, String(describing: responseModel))
                completion(.success(responseModel))
            } catch {
                // Fallback: if the response is a bare number, try to parse it.
                if let responseString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   let responseInt = Int(responseString) {
                    os_log("Parsed bare response code: %d", log: OSLog.default, type: .debug, responseInt)
                    // Create a dummy ResponseFormat
                    let dummyAuth = ResponseData.AuthInfo(anonymizedID: "")
                    let dummyResponseData = ResponseData(authInfo: dummyAuth, responseCode: responseInt)
                    let dummyResponseFormat = ResponseFormat(responseData: dummyResponseData)
                    completion(.success(dummyResponseFormat))
                } else {
                    os_log("Error decoding response: %@", log: OSLog.default, type: .error, error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Helper function to check if the user has given consent
    private func hasUserConsented() -> Bool {
        if let consent = UserDefaults.standard.object(forKey: "hasConsentedToSendData") as? Bool {
            return consent
        }
        os_log("CloudManager: Consent is not set, defaulting to NO.", log: OSLog.default, type: .info)
        return false
    }
    
    public func canSendData() -> Bool {
    // Additional checks before sending data
        guard hasUserConsented() else {
            os_log("CloudManager: User has not consented to sending data.", log: OSLog.default, type: .info)
            return false
        }
        return true
    }
    
    // MARK: - Public API Methods
    
    /// Sends HRV data and returns the server's response code.
    func sendHRVData(request: AddHRVDataRequest,
                     completion: @escaping (Result<Int, Error>) -> Void) {
        guard canSendData() else {
            os_log("CloudManager: User has not consented to sending HRV data. Skipping.", log: OSLog.default, type: .info)
            completion(.failure(NSError(domain: "CloudManager", code: 403, userInfo: [NSLocalizedDescriptionKey: "User has not consented"])))
            return
        }
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                os_log("Final HRV JSON being sent: %@", log: OSLog.default, type: .debug, jsonString)
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        performPostRequest(with: urlRequest) { result in
            switch result {
            case .success(let responseFormat):
                let responseCode = responseFormat.responseData.responseCode
                os_log("Parsed Response Code: %d", log: OSLog.default, type: .debug, responseCode)
                completion(.success(responseCode))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sends questionnaire data. Assumes that a response code of 10 indicates success.
    func sendQuestionnaireData(request: QuestionnaireRequest,
                               completion: @escaping (Result<Void, Error>) -> Void) {
        guard canSendData() else {
            os_log("CloudManager: User has not consented to sending questionnaire data. Skipping.", log: OSLog.default, type: .info)
            completion(.failure(NSError(domain: "CloudManager", code: 403, userInfo: [NSLocalizedDescriptionKey: "User has not consented"])))
            return
        }
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
        performPostRequest(with: urlRequest) { result in
            switch result {
            case .success(let responseFormat):
                let responseCode = responseFormat.responseData.responseCode
                os_log("Parsed Response Code: %d", log: OSLog.default, type: .debug, responseCode)
                if responseCode == 10 {
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "CloudManager",
                                        code: responseCode,
                                        userInfo: [NSLocalizedDescriptionKey: "Server returned error code \(responseCode)"])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sends a medication update. Assumes a response code of 10 indicates success.
    func sendMedicationUpdate(request: MedicationUpdateRequest,
                              completion: @escaping (Result<Void, Error>) -> Void) {
        guard canSendData() else {
            os_log("CloudManager: User has not consented to sending medication data. Skipping.", log: OSLog.default, type: .info)
            completion(.failure(NSError(domain: "CloudManager", code: 403, userInfo: [NSLocalizedDescriptionKey: "User has not consented"])))
            return
        }
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        performPostRequest(with: urlRequest) { result in
            switch result {
            case .success(let responseFormat):
                let responseCode = responseFormat.responseData.responseCode
                os_log("Parsed Response Code: %d", log: OSLog.default, type: .debug, responseCode)
                if responseCode == 10 {
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "CloudManager",
                                        code: responseCode,
                                        userInfo: [NSLocalizedDescriptionKey: "Server returned error code \(responseCode)"])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Sends or updates user data.
    func addOrUpdateUser(userData: UserProfile,
                         completion: @escaping (Result<Void, Error>) -> Void) {
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(userData)
            urlRequest.httpBody = jsonData
            os_log("Sending user profile: %@", log: OSLog.default, type: .debug, String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")
        } catch {
            os_log("Failed to encode user profile: %@", log: OSLog.default, type: .error, error.localizedDescription)
            completion(.failure(error))
            return
        }
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                os_log("Network error: %@", log: OSLog.default, type: .error, error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                let unknownError = NSError(domain: "CloudManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown response"])
                completion(.failure(unknownError))
                return
            }
            os_log("HTTP Status Code: %d", log: OSLog.default, type: .info, httpResponse.statusCode)
            if !(200..<300).contains(httpResponse.statusCode) {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    os_log("Response Data: %@", log: OSLog.default, type: .error, responseString)
                }
                let error = NSError(domain: "CloudManager", code: httpResponse.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                completion(.failure(error))
                return
            }
            os_log("User profile updated successfully", log: OSLog.default, type: .info)
            completion(.success(()))
        }.resume()
    }
    
    /// Sends a create user request.
    func sendCreateUser(request: CreateUserRequest,
                        completion: @escaping (Result<(String, String), Error>) -> Void) {
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(request)
            urlRequest.httpBody = jsonData
            os_log("Sending CreateUser request: %@", log: OSLog.default, type: .debug, String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")
        } catch {
            os_log("Failed to serialize CreateUser JSON: %@", log: OSLog.default, type: .error, error.localizedDescription)
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                os_log("Network error: %@", log: OSLog.default, type: .error, error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                os_log("HTTP Status Code: %d", log: OSLog.default, type: .info, httpResponse.statusCode)
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    os_log("Response Body: %@", log: OSLog.default, type: .debug, responseString)
                    
                    // Split response into User Name GUID and User ID GUID
                    let components = responseString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",")
                    if components.count == 2 {
                        let userNameGUID = components[0]
                        let accessKeyGUID = components[1]

                        os_log("✅ Retrieved User Name GUID: %@", log: OSLog.default, type: .info, userNameGUID)
                        os_log("✅ Retrieved Access Key GUID: %@", log: OSLog.default, type: .info, accessKeyGUID)

                        // Store GUIDs in UserDefaults
                        UserDefaults.standard.set(userNameGUID, forKey: "AnonymizedID")
                        UserDefaults.standard.set(accessKeyGUID, forKey: "AccessKey")
                        UserDefaults.standard.synchronize()

                        completion(.success((userNameGUID, accessKeyGUID)))
                        return
                    } else {
                        os_log("🚨 Response format unexpected: %@", log: OSLog.default, type: .error, responseString)
                        let formatError = NSError(domain: "CloudManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])
                        completion(.failure(formatError))
                        return
                    }
                }
                
                if !(200..<300).contains(httpResponse.statusCode) {
                    let error = NSError(domain: "CloudManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                    completion(.failure(error))
                    return
                }
            }
            
            let unknownError = NSError(domain: "CloudManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown response"])
            completion(.failure(unknownError))
        }.resume()
    }
    
    // MARK: - Response Format Model
    
    struct ResponseData: Codable {
        struct AuthInfo: Codable {
            let anonymizedID: String

            enum CodingKeys: String, CodingKey {
                case anonymizedID = "AnonymizedID"
            }
        }
        
        let authInfo: AuthInfo
        let responseCode: Int

        enum CodingKeys: String, CodingKey {
            case authInfo = "AuthInfo"
            case responseCode = "ResponseCode"
        }
    }

    struct ResponseFormat: Codable {
        let responseData: ResponseData

        enum OuterKeys: String, CodingKey {
            case responseData = "ResponseData"
        }
    }
}
