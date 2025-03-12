//
//  OnboardingViewModel.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 2/25/25.
//

import SwiftUI
import os.log

class OnboardingViewModel: ObservableObject {
    // User inputs for height, weight, hospital, age, and injury.
    @Published var heightText: String = ""
    @Published var weightText: String = ""
    @Published var hospitalName: String = ""
    @Published var ageText: String = ""
    @Published var injuryType: String = ""
    @Published var injuryDate: Date = Date()
    @Published var gender: String = ""
    
    // Unit selections.
    @Published var selectedHeightUnit: HeightUnit = .inches
    @Published var selectedWeightUnit: WeightUnit = .pounds
    
    // Medications: user can add as many as they want.
    @Published var medications: [Medication] = []
    
    // For showing a local confirmation alert.
    @Published var showConfirmation: Bool = false
    
    // Logger using OSLog.
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.yourapp.HRVMonitoring", category: "OnboardingViewModel")
    
    /// Checks that required fields are valid. Medications are optional, but if present, they must have non-empty names.
    var isFormValid: Bool {
        let trimmedHeight = heightText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWeight = weightText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHospital = hospitalName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAge = ageText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInjuryType = injuryType.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGender = gender.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedHeight.isEmpty,
              !trimmedWeight.isEmpty,
              !trimmedHospital.isEmpty,
              !trimmedAge.isEmpty,
              !trimmedInjuryType.isEmpty,
              !trimmedGender.isEmpty,
              Double(trimmedHeight) != nil,
              Double(trimmedWeight) != nil,
              Int(trimmedAge) != nil else {
            return false
        }
        // Medications: if any exist, each must have a non-empty medication string.
        let medicationsValid = medications.allSatisfy { !$0.medication.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return medications.isEmpty || medicationsValid
    }
    
    // Adds a new empty medication entry.
    func addMedication() {
        let newMedNumber = medications.count + 1
        let newMedication = Medication(id: UUID().uuidString, medicationNumber: newMedNumber, medication: "")
        medications.append(newMedication)
    }
    
    // Optionally, you might implement removal.
    func removeMedication(at index: Int) {
        medications.remove(at: index)
        // Re-number medications sequentially.
        for i in 0..<medications.count {
            medications[i].medicationNumber = i + 1
        }
    }
    
    func sendMedicationUpdate() {
        guard let userID = UserDefaults.standard.string(forKey: "AnonymizedID"),
              let accessKey = UserDefaults.standard.string(forKey: "AccessKey") else {
            os_log("🚨 Missing user credentials. Cannot send medications.", log: self.logger, type: .error)
            return
        }

        let medicationList = medications.map { $0.medication }.filter { !$0.isEmpty }
        
        guard !medicationList.isEmpty else {
            os_log("⚠️ No medications to send. Skipping update.", log: self.logger, type: .info)
            return
        }

        let authInfo = AuthInfo(anonymizedID: userID, accessKey: accessKey)
        let requestData = MedicationUpdateRequest.RequestData(authInfo: authInfo, type: "UpdateMedications", medications: medicationList)
        
        let medicationUpdateRequest = MedicationUpdateRequest(requestData: requestData)

        os_log("🚀 Sending Medications: %@", log: self.logger, type: .info, medicationList.description)

        CloudManager.shared.sendMedicationUpdate(request: medicationUpdateRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    os_log("✅ Medications updated successfully.", log: self.logger, type: .info)
                case .failure(let error):
                    os_log("🚨 Failed to update medications: %@", log: self.logger, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    // Called when the user taps "Complete Onboarding".
    func completeOnboarding() {
        let userID = retrieveOrGenerateUserID()

        // Store onboarding completion status.
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        UserDefaults.standard.synchronize()  // Ensure it’s saved immediately

        // Create AuthInfo object.
        let authInfo = CreateUserRequest.AuthInfo(
            anonymizedID: userID,
            accessKey: UUID().uuidString // Generate a placeholder access key for first-time creation
        )

        // Create RequestData object.
        let requestData = CreateUserRequest.RequestData(
            authInfo: authInfo,
            type: "CreateUser"
        )

        let requestBody = CreateUserRequest.Body(requestData: requestData)
        let createUserRequest = CreateUserRequest(body: requestBody)

        // Store the user anonymized ID.
        UserDefaults.standard.set(userID, forKey: "AnonymizedID")

        CloudManager.shared.sendCreateUser(request: createUserRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (userNameGUID, accessKeyGUID)):
                    os_log("✅ User successfully created!", log: self.logger, type: .info)
                    UserDefaults.standard.set(userNameGUID, forKey: "AnonymizedID")
                    UserDefaults.standard.set(accessKeyGUID, forKey: "AccessKey")
                    
                    // Set the user profile details from onboarding.
                    UserDefaults.standard.set(self.hospitalName, forKey: "HospitalName")
                    if let age = Int(self.ageText) {
                        UserDefaults.standard.set(age, forKey: "Age")
                    }
                    // Compute BMI from height and weight.
                    if let height = Double(self.heightText), let weight = Double(self.weightText) {
                        let heightInMeters = self.convertHeightToMeters(value: height, unit: self.selectedHeightUnit)
                        let weightInKg = self.convertWeightToKg(value: weight, unit: self.selectedWeightUnit)
                        let bmiValue = weightInKg / (heightInMeters * heightInMeters)
                        UserDefaults.standard.set(bmiValue, forKey: "BMI")
                    }
                    // Save gender, injury type, and injury date.
                    UserDefaults.standard.set(self.gender, forKey: "Gender")
                    UserDefaults.standard.set(self.injuryType, forKey: "InjuryType")
                    UserDefaults.standard.set(self.injuryDate, forKey: "InjuryDate")
                    
                    // Synchronize UserDefaults.
                    UserDefaults.standard.synchronize()
                    
                    self.sendMedicationUpdate()
                case .failure(let error):
                    os_log("🚨 Failed to create user: %@", log: self.logger, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func retrieveOrGenerateUserID() -> String {
        if let existingID = UserDefaults.standard.string(forKey: "AnonymizedID") {
            return existingID
        } else {
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: "AnonymizedID")
            return newID
        }
    }
    
    private func convertHeightToMeters(value: Double, unit: HeightUnit) -> Double {
        switch unit {
        case .centimeters:
            return value / 100.0
        case .inches:
            return value * 0.0254
        }
    }
    
    private func convertWeightToKg(value: Double, unit: WeightUnit) -> Double {
        switch unit {
        case .kilograms:
            return value
        case .pounds:
            return value * 0.45359237
        }
    }
}
