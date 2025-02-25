//
//  OnboardingModel.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 2/25/25.
//

import Foundation

/// Enumerations for the user's preferred units.
enum HeightUnit: String, CaseIterable {
    case centimeters = "cm"
    case inches = "in"
}

enum WeightUnit: String, CaseIterable {
    case kilograms = "kg"
    case pounds = "lbs"
}

/// A simple data model representing the user's profile for onboarding.
struct UserProfile: Codable {
    let anonymizedID: String
    let height: Double
    let weight: Double
    let bmi: Double
    let hospitalName: String
    let heightUnit: String
    let weightUnit: String
}
