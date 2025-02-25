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

    @Published var selectedHeightUnit: HeightUnit = .inches
    @Published var selectedWeightUnit: WeightUnit = .pounds

    // For showing a local confirmation alert in the view
    @Published var showConfirmation: Bool = false

    /// Called when user taps "Complete Onboarding"
    func completeOnboarding() {
        // 1) Generate or retrieve user ID
        let userID = retrieveOrGenerateUserID()

        // 2) Convert user input to Double
        let heightVal = Double(heightText) ?? 0.0
        let weightVal = Double(weightText) ?? 0.0

        // 3) Convert to metric
        let heightMeters = convertHeightToMeters(value: heightVal, unit: selectedHeightUnit)
        let weightKg = convertWeightToKg(value: weightVal, unit: selectedWeightUnit)

        // 4) Calculate BMI
        let bmi = (heightMeters > 0) ? (weightKg / (heightMeters * heightMeters)) : 0

        // 5) Build user profile
        let userData = UserProfile(
            anonymizedID: userID,
            height: heightVal,
            weight: weightVal,
            bmi: bmi,
            hospitalName: hospitalName,
            heightUnit: selectedHeightUnit.rawValue,
            weightUnit: selectedWeightUnit.rawValue
        )

        // 6) Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")

        // 7) (Optional) Send data to your backend
        // CloudManager.shared.addOrUpdateUser(userData: userData) { result in
        //     switch result {
        //     case .success:
        //         print("User data uploaded successfully")
        //     case .failure(let error):
        //         print("Failed to upload user data:", error)
        //     }
        // }

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
