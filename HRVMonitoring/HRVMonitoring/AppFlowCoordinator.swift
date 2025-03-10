//
//  AppFlowCoordinator.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/3/25.
//

import SwiftUI

struct AppFlowCoordinator: View {
    @State private var stage: AppStage = .onboarding

    var body: some View {
        Group {
            switch stage {
            case .onboarding:
                OnboardingView {
                    // When onboarding completes, show the explanation page.
                    stage = .explanation
                }
            case .explanation:
                GAD7ExplanationView {
                    // When the user taps continue, move to the questionnaire.
                    stage = .questionnaire
                }
            case .questionnaire:
                QuestionnaireContainerView {
                    let now = Date()
                    UserDefaults.standard.set(now, forKey: "LastQuestionnaireDate")
                    stage = .main
                }
            case .main:
                NavigationScreenView()
            }
        }
        .onAppear {
            // Determine the initial stage based on stored values.
            let onboarded = UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
            if !onboarded {
                stage = .onboarding
            } else {
                let lastDate = UserDefaults.standard.object(forKey: "LastQuestionnaireDate") as? Date
                if lastDate == nil || Date().timeIntervalSince(lastDate!) > 14 * 24 * 60 * 60 {
                    stage = .explanation
                } else {
                    stage = .main
                }
            }
        }
    }
}

