//
//  OnboardingViewModel.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 2/25/25.
//

import SwiftUI

/// Handles the logic of onboarding: unit conversion, BMI calculation,
/// user defaults, and optionally calling CloudManager.
class OnboardingViewModel: ObservableObject {
    // Published properties that the view can bind to.
    @Published var heightText: String = ""
    @Published var weightText: String = ""
    @Published var hospitalName: String = ""
    @Published var ageText: String = ""
    @Published var injuryType: String = ""
    @Published var injuryDate: Date = Date()  // Default to today
    
    @Published var selectedHeightUnit: HeightUnit = .inches
    @Published var selectedWeightUnit: WeightUnit = .pounds

    @Published var showConfirmation: Bool = false

    /// A computed property that ensures the user has entered non-empty, valid values.
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
        return true
    }
    /// Called when user taps "Complete Onboarding"
    func completeOnboarding() {
        // 1) Generate or retrieve user ID
        let userID = retrieveOrGenerateUserID()

        // 2) Convert user input to Double
        let heightVal = Double(heightText) ?? 0.0
        let weightVal = Double(weightText) ?? 0.0
        let age = Int(ageText) ?? 0
        
        // 3) Convert height and weight to metric.
        let heightMeters = convertHeightToMeters(value: heightVal, unit: selectedHeightUnit)
        let weightKg = convertWeightToKg(value: weightVal, unit: selectedWeightUnit)
        
        // 4) Calculate BMI (kg / m^2).
        let bmi = (heightMeters > 0) ? (weightKg / (heightMeters * heightMeters)) : 0

        // 5) Build user profile data
        let userData = UserProfile(
            anonymizedID: userID,
            bmi: bmi,
            hospitalName: hospitalName,
            age: age,
            injuryType: injuryType,
            injuryDate: injuryDate
        )
        
        // 6) Mark onboarding as completed.
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")

        // 7) Send user data to your backend
        CloudManager.shared.addOrUpdateUser(userData: userData) { result in
            switch result {
            case .success:
                print("User data uploaded successfully")
            case .failure(let error):
                print("Failed to upload user data:", error)
            }
        }

        // 8) Show a local success alert
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
