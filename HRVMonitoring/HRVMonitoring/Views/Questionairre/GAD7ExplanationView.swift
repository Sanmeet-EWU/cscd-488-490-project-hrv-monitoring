//
//  GAD7ExplanationView.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/4/25.
//

import SwiftUI

struct GAD7ExplanationView: View {
    /// Called when the user taps Continue.
    var onContinue: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("GAD‑7 Questionnaire")
                    .font(.largeTitle)
                    .padding(.top)
                
                Text("The GAD‑7 is a validated screening tool used to assess the severity of generalized anxiety disorder. It consists of 7 questions about your feelings over the past two weeks. Your responses help gauge your anxiety levels and can guide further steps in your care.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: onContinue) {
                    Text("Continue")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("About the GAD‑7")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GAD7ExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        GAD7ExplanationView {
            print("Continue tapped")
        }
    }
}
