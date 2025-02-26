//
//  OnboardingView.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 2/25/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var navigateToHome = false  // Controls navigation to ContentView

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome! Let's set up your profile.")
                    .font(.title)
                    .padding(.top, 40)
                
                // Height input + unit picker
                TextField("Height", text: $viewModel.heightText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .padding([.leading, .trailing])
                
                Picker("Height Unit", selection: $viewModel.selectedHeightUnit) {
                    Text("in").tag(HeightUnit.inches)
                    Text("cm").tag(HeightUnit.centimeters)
                }
                .pickerStyle(.segmented)
                .padding([.leading, .trailing])
                
                // Weight input + unit picker
                TextField("Weight", text: $viewModel.weightText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .padding([.leading, .trailing])
                
                Picker("Weight Unit", selection: $viewModel.selectedWeightUnit) {
                    Text("lbs").tag(WeightUnit.pounds)
                    Text("kg").tag(WeightUnit.kilograms)
                }
                .pickerStyle(.segmented)
                .padding([.leading, .trailing])
                
                // Hospital name
                TextField("Hospital Name", text: $viewModel.hospitalName)
                    .textFieldStyle(.roundedBorder)
                    .padding([.leading, .trailing])
                
                Spacer()
                
                Button("Complete Onboarding") {
                    viewModel.completeOnboarding()
                    // After completing onboarding, navigate to HomeScreenView.
                    navigateToHome = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
                .disabled(!viewModel.isFormValid)
                .alert("Profile Saved!", isPresented: $viewModel.showConfirmation) {
                    Button("OK", role: .cancel) { }
                }
            }
            .navigationTitle("Onboarding")
            // Navigation destination triggered when navigateToHome becomes true.
            .navigationDestination(isPresented: $navigateToHome) {
                ContentView().navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
