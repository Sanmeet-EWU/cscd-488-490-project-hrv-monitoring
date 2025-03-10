//
//  MockDataTestView.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/7/25.
//

import SwiftUI

struct MockDataTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Mock Data Testing")
                .font(.title)
                .padding()
            
            Button("Send Mock HRV Data") {
                sendMockHRVData()
            }
            
            Button("Send Mock Questionnaire Data") {
                sendMockQuestionnaireData()
            }
            
            Button("Send Mock Medication Update") {
                sendMockMedicationUpdate()
            }
            
            Button("Send Create User Request") {
                sendMockCreateUserRequest()
            }
        }
        .padding()
    }
    
    func sendMockHRVData() {
        guard let fileURL = Bundle.main.url(forResource: "mockHRVData", withExtension: "json") else {
            print("📂 [Error] mockHRVData.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            print("📥 Successfully loaded mockHRVData.json")
            
            // Retrieve credentials using the correct keys
            guard let anonymizedID = UserDefaults.standard.string(forKey: "AnonymizedID"),
                  let accessKey = UserDefaults.standard.string(forKey: "AccessKey") else {
                print("🚨 User GUIDs not found! Have you created a user first?")
                return
            }
            print("🔄 Inserting User GUIDs into HRV Data")
            
            // Use JSONSerialization to update the JSON payload dynamically
            if var jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               var body = jsonObject["body"] as? [String: Any],
               var requestData = body["RequestData"] as? [String: Any],
               var authInfo = requestData["AuthInfo"] as? [String: Any] {
                
                // Update AuthInfo with the correct credentials
                authInfo["AnonymizedID"] = anonymizedID
                authInfo["AccessKey"] = accessKey
                requestData["AuthInfo"] = authInfo
                
                // Add CreationDate with uppercase "C" as expected by the backend
                requestData["CreationDate"] = "2025-02-25T00:00:00Z"
                
                // Override HRVInfo to match the working payload
                requestData["HRVInfo"] = [
                    "SDNN": 50.5,
                    "RMSSD": 40.7,
                    "PNN50": 85.3,
                    "HeartBeats": [70, 72, 68, 75]
                ]
                
                // Override PersonalData to match the working payload (including Gender)
                requestData["PersonalData"] = [
                    "Age": 30,
                    "BMI": 22.5,
                    "Gender": "Male",
                    "HospitalName": "Sample Hospital",
                    "Injury": [
                        "Type": "Sprained Ankle", // Updated key "Type"
                        "Date": "2025-01-10"
                    ]
                ]
                
                // Ensure the Type field is correct
                requestData["Type"] = "AddData"
                
                // Update the body and overall JSON object
                body["RequestData"] = requestData
                jsonObject["body"] = body
                
                // Re-encode the updated JSON object to Data
                let updatedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
                if let finalJSONString = String(data: updatedData, encoding: .utf8) {
                    print("📜 Updated HRV Data with GUIDs: \(finalJSONString)")
                }
                
                // Decode the updated data into your AddHRVDataRequest model
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let request = try decoder.decode(AddHRVDataRequest.self, from: updatedData)
                
                // Send the HRV data using your CloudManager
                CloudManager.shared.sendHRVData(request: request) { result in
                    switch result {
                    case .success(let responseCode):
                        print("✅ Successfully sent HRV data! Response Code: \(responseCode)")
                    case .failure(let error):
                        print("🚨 Error sending HRV data: \(error.localizedDescription)")
                    }
                }
            } else {
                print("🚨❌ Error updating AuthInfo in HRV data")
            }
        } catch {
            print("🚨❌ Error reading/updating mockHRVData.json: \(error)")
        }
    }

    
    
    // MARK: - 2) Send Mock Questionnaire Data
    func sendMockQuestionnaireData() {
        guard let fileURL = Bundle.main.url(forResource: "mockQuestionaireUpdate", withExtension: "json") else {
            print("📂 [Error] mockQuestionaireUpdate.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            print("📥 Successfully loaded mockQuestionaireUpdate.json")
            
            // Retrieve GUIDs from UserDefaults.
            guard let anonymizedID = UserDefaults.standard.string(forKey: "AnonymizedID"),
                  let accessKey = UserDefaults.standard.string(forKey: "AccessKey") else {
                print("🚨 User GUIDs not found! Have you created a user first?")
                return
            }
            
            // Update the JSON payload to include the proper GUIDs.
            if var jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               var body = jsonObject["body"] as? [String: Any],
               var requestData = body["RequestData"] as? [String: Any],
               var authInfo = requestData["AuthInfo"] as? [String: Any] {
                
                authInfo["AnonymizedID"] = anonymizedID
                authInfo["AccessKey"] = accessKey
                requestData["AuthInfo"] = authInfo
                body["RequestData"] = requestData
                jsonObject["body"] = body
                
                let updatedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                
                let decoder = JSONDecoder()
                let request = try decoder.decode(QuestionnaireRequest.self, from: updatedData)
                
                CloudManager.shared.sendQuestionnaireData(request: request) { result in
                    switch result {
                    case .success:
                        print("🚀✅ Mock questionnaire data sent successfully!")
                    case .failure(let error):
                        print("🚨❌ Failed to send mock questionnaire data: \(error.localizedDescription)")
                    }
                }
            } else {
                print("🚨❌ Error updating AuthInfo in mock questionnaire data")
            }
        } catch {
            print("🚨❌ Error reading/decoding mockQuestionaireUpdate.json: \(error)")
        }
    }

    
    // MARK: - 3) Send Mock Medication Update
    func sendMockMedicationUpdate() {
        guard let fileURL = Bundle.main.url(forResource: "mockMedicationUpdate", withExtension: "json") else {
            print("📂 [Error] mockMedicationUpdate.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            print("📥 Successfully loaded mockMedicationUpdate.json")
            
            // Retrieve the correct authentication IDs from UserDefaults.
            guard let anonymizedID = UserDefaults.standard.string(forKey: "AnonymizedID"),
                  let accessKey = UserDefaults.standard.string(forKey: "AccessKey") else {
                print("🚨 Credentials not found. Make sure the user is created and the values are stored.")
                return
            }
            
            // Debug: Print the AuthInfo values being sent
            print("Debug: Sending Medication Update AuthInfo - AnonymizedID: \(anonymizedID), AccessKey: \(accessKey)")
            
            // Update the JSON payload with the correct AuthInfo values.
            if var jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               var body = jsonObject["body"] as? [String: Any],
               var requestData = body["RequestData"] as? [String: Any],
               var authInfo = requestData["AuthInfo"] as? [String: Any] {
                
                authInfo["AnonymizedID"] = anonymizedID
                authInfo["AccessKey"] = accessKey
                requestData["AuthInfo"] = authInfo
                body["RequestData"] = requestData
                jsonObject["body"] = body
                
                let updatedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                
                let decoder = JSONDecoder()
                let request = try decoder.decode(MedicationUpdateRequest.self, from: updatedData)
                
                CloudManager.shared.sendMedicationUpdate(request: request) { result in
                    switch result {
                    case .success:
                        print("✅ Successfully sent Medication Update!")
                    case .failure(let error):
                        print("🚨 Error sending Medication Update: \(error.localizedDescription)")
                    }
                }
            } else {
                print("🚨❌ Error updating AuthInfo in medication update data")
            }
        } catch {
            print("🚨❌ Error reading/decoding mockMedicationUpdate.json: \(error)")
        }
    }


    
    // MARK: - 4) Send Mock Create User Request
    func sendMockCreateUserRequest() {
        guard let fileURL = Bundle.main.url(forResource: "mockCreateUser", withExtension: "json") else {
            print("📂 [Error] mockCreateUser.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            print("📥 Successfully loaded mockCreateUser.json")

            // Debug print the raw JSON data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 JSON Content: \(jsonString)")
            }

            // Decode the JSON into CreateUserRequest struct
            let decoder = JSONDecoder()
            let request = try decoder.decode(CreateUserRequest.self, from: data)

            // Send request to the server
            CloudManager.shared.sendCreateUser(request: request) { result in
                switch result {
                case .success(let (userNameGUID, userIDGUID)):
                    print("✅ Successfully created user!")
                    print("🆔 User Name GUID: \(userNameGUID)")
                    print("🆔 User ID GUID: \(userIDGUID)")
                    
                    // Store GUIDs using the keys expected by AuthInfo
                    UserDefaults.standard.set(userNameGUID, forKey: "AnonymizedID")
                    UserDefaults.standard.set(userIDGUID, forKey: "AccessKey")
                    
                case .failure(let error):
                    print("🚨 Error creating user: \(error.localizedDescription)")
                }
            }
        } catch {
            print("🚨❌ Error reading/decoding mockCreateUser.json: \(error)")
        }
    }
}
