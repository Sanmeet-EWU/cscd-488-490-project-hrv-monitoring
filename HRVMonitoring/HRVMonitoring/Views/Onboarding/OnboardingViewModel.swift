//
//  OnboardingViewModel.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 2/25/25.
//

import SwiftUI

class OnboardingViewModel: ObservableObject {
    // User inputs for height, weight, hospital, age, and injury.
    @Published var heightText: String = ""
    @Published var weightText: String = ""
    @Published var hospitalName: String = ""
    @Published var ageText: String = ""
    @Published var injuryType: String = ""
    @Published var injuryDate: Date = Date()
    
    // Unit selections.
    @Published var selectedHeightUnit: HeightUnit = .inches
    @Published var selectedWeightUnit: WeightUnit = .pounds
    
    // Medications: user can add as many as they want.
    @Published var medications: [Medication] = []
    
    // For showing a local confirmation alert.
    @Published var showConfirmation: Bool = false
    
    /// Checks that required fields are valid. Medications are optional, but if present, they must have non-empty names.
    var isFormValid: Bool {
        let trimmedHeight = heightText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWeight = weightText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHospital = hospitalName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAge = ageText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInjuryType = injuryType.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedHeight.isEmpty,
              !trimmedWeight.isEmpty,
              !trimmedHospital.isEmpty,
              !trimmedAge.isEmpty,
              !trimmedInjuryType.isEmpty,
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
    
    // Called when the user taps "Complete Onboarding".
    func completeOnboarding() {
        let userID = retrieveOrGenerateUserID()
        let heightVal = Double(heightText) ?? 0.0
        let weightVal = Double(weightText) ?? 0.0
        let age = Int(ageText) ?? 0
        
        let heightMeters = convertHeightToMeters(value: heightVal, unit: selectedHeightUnit)
        let weightKg = convertWeightToKg(value: weightVal, unit: selectedWeightUnit)
        
        let bmi = (heightMeters > 0) ? (weightKg / (heightMeters * heightMeters)) : 0
        
        // Build the user profile using only the required fields.
        let userData = UserProfile(
            anonymizedID: userID,
            bmi: bmi,
            hospitalName: hospitalName,
            age: age,
            injuryType: injuryType,
            injuryDate: injuryDate,
            medications: medications
        )
        
        // Mark onboarding as completed.
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        
        // Send the user profile to your backend.
        CloudManager.shared.addOrUpdateUser(userData: userData) { result in
            switch result {
            case .success:
                print("User data uploaded successfully")
            case .failure(let error):
                print("Failed to upload user data: \(error)")
            }
        }
        
        showConfirmation = true
        print("Onboarding complete. ID: \(userID), BMI: \(bmi)")
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

