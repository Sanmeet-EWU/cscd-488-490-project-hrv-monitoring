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
        print("🔘 Button tapped: Send Mock HRV Data")
        guard let fileURL = Bundle.main.url(forResource: "mockHRVData",
                                            withExtension: "json")
        else {
            print("📂 [Error] mockHRVData.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            print("📥 Successfully loaded mockHRVData.json")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let request = try decoder.decode(AddHRVDataRequest.self, from: data)
            
            CloudManager.shared.sendHRVData(request: request) { result in
                switch result {
                case .success:
                    print("🚀✅ Mock HRV data sent successfully!")
                case .failure(let error):
                    print("🚨❌ Failed to send mock HRV data: \(error.localizedDescription)")
                }
            }
        } catch {
            print("🚨❌ Error reading/decoding mockHRVData.json: \(error)")
        }
    }
    
    // MARK: - 2) Send Mock Questionnaire Data
    func sendMockQuestionnaireData() {
        guard let fileURL = Bundle.main.url(forResource: "mockQuestionaireUpdate",
                                            withExtension: "json",
                                            subdirectory: "Networking/MockData") else {
            print("📂 [Error] mockQuestionaireUpdate.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            print("📥 Successfully loaded mockQuestionaireUpdate.json")
            let decoder = JSONDecoder()
            // If your questionnaire includes dates, set decoder.dateDecodingStrategy
            let request = try decoder.decode(QuestionnaireRequest.self, from: data)
            
            CloudManager.shared.sendQuestionnaireData(request: request) { result in
                switch result {
                case .success:
                    print("🚀✅ Mock questionnaire data sent successfully!")
                case .failure(let error):
                    print("🚨❌ Failed to send mock questionnaire data: \(error.localizedDescription)")
                }
            }
        } catch {
            print("🚨❌ Error reading/decoding mockQuestionaireUpdate.json: \(error)")
        }
    }
    
    // MARK: - 3) Send Mock Medication Update
    func sendMockMedicationUpdate() {
        guard let fileURL = Bundle.main.url(forResource: "mockMedicationUpdate",
                                            withExtension: "json",
                                            subdirectory: "Networking/MockData") else {
            print("📂 [Error] mockMedicationUpdate.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            print("📥 Successfully loaded mockMedicationUpdate.json")
            let decoder = JSONDecoder()
            // If you have a MedicationUpdateRequest struct, decode it here:
            // let request = try decoder.decode(MedicationUpdateRequest.self, from: data)
            // Then call your CloudManager function for medication updates.
            print("💡 [Note] Decoding and sending for Medication Update not implemented yet.")
            // Example:
            // CloudManager.shared.sendMedicationUpdate(request: request) { result in
            //     switch result { ... }
            // }
        } catch {
            print("🚨❌ Error reading/decoding mockMedicationUpdate.json: \(error)")
        }
    }
    
    // MARK: - 4) Send Mock Create User Request
    func sendMockCreateUserRequest() {
        guard let fileURL = Bundle.main.url(forResource: "mockCreateUser",
                                            withExtension: "json",
                                            subdirectory: "Networking/MockData") else {
            print("📂 [Error] mockCreateUser.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            print("📥 Successfully loaded mockCreateUser.json")
            // If you have a CreateUserRequest struct, decode it here:
            // let decoder = JSONDecoder()
            // let request = try decoder.decode(CreateUserRequest.self, from: data)
            print("💡 [Note] Decoding and sending for Create User not implemented yet.")
            // Then call your CloudManager function for creating a user, e.g.:
            // CloudManager.shared.createUser(request: request) { result in
            //     switch result { ... }
            // }
        } catch {
            print("🚨❌ Error reading/decoding mockCreateUser.json: \(error)")
        }
    }
}
