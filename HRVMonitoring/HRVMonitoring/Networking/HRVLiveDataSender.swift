//
//  HRVLiveDataSender.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/11/25.
//

import Foundation

class HRVLiveDataSender {
    static let shared = HRVLiveDataSender()
    
    func sendLiveHRVData(using hrvCalculator: HRVCalculator) {
        // Retrieve live HRV metrics from HRVCalculator.
        guard let hrvInfo = buildHRVInfo(from: hrvCalculator) else {
            print("HRV metrics are not available yet.")
            return
        }
        
        // Retrieve authentication information from UserDefaults.
        guard let anonymizedID = UserDefaults.standard.string(forKey: "AnonymizedID"),
              let accessKey = UserDefaults.standard.string(forKey: "AccessKey") else {
            print("Missing authentication credentials.")
            return
        }
        
        let authInfo = AddHRVDataRequest.AuthInfo(anonymizedID: anonymizedID, accessKey: accessKey)
        
        // Retrieve user profile values saved during onboarding.
        let hospitalName = UserDefaults.standard.string(forKey: "HospitalName") ?? "Default Hospital"
        let age = UserDefaults.standard.integer(forKey: "Age") // returns 0 if not set
        let bmi = UserDefaults.standard.double(forKey: "BMI")    // returns 0.0 if not set
        let gender = UserDefaults.standard.string(forKey: "Gender") // optional
        let injuryType = UserDefaults.standard.string(forKey: "InjuryType") ?? "None"
        let injuryDate = UserDefaults.standard.object(forKey: "InjuryDate") as? Date ?? Date()
        
        let personalData = AddHRVDataRequest.PersonalData(
            age: age,
            bmi: bmi,
            gender: gender,
            hospitalName: hospitalName,
            injury: AddHRVDataRequest.Injury(type: injuryType, date: injuryDate)
        )
        
        // Build Flags (adjust if you have any custom logic here).
        let flags = AddHRVDataRequest.Flags(userFlagged: false, programFlagged: false)
        
        // Construct the request data using the live HRV metrics and the saved personal data.
        let requestData = AddHRVDataRequest.RequestData(
            authInfo: authInfo,
            type: "AddData",           // Must match the expected type on your backend.
            creationDate: Date(),      // Using current date/time.
            hrvInfo: hrvInfo,
            flags: flags,
            personalData: personalData
        )
        
        // Wrap the requestData inside the outer "body" structure.
        let liveHRVRequest = AddHRVDataRequest(requestData: requestData)
        
        // Send the live HRV data via CloudManager.
        CloudManager.shared.sendHRVData(request: liveHRVRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseCode):
                    print("Live HRV data sent successfully. Response code: \(responseCode)")
                case .failure(let error):
                    print("Failed to send live HRV data: \(error.localizedDescription)")
                }
            }
        }
    }

}
