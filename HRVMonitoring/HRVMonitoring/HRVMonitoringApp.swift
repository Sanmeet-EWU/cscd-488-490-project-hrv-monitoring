//
//  HRVMonitoringApp.swift
//  HRVMonitoring
//
//  Created by William Reese on 2/17/25.
//

import SwiftUI

@main
struct HRVMonitoringApp: App {
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
                    .onDisappear {
                        // Re-check if user completed onboarding
                        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
                    }
            }
        }
    }
}
