//
//  QuestionairreContainerView.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/3/25.
//

import SwiftUI

struct QuestionnaireContainerView: View {
    let questions: [QuestionnaireQuestion] = [
        QuestionnaireQuestion(id: 0, text: "Over the last two weeks, how often did you feel nervous, anxious, or on edge?"),
        QuestionnaireQuestion(id: 1, text: "Over the last two weeks, how often did you worry too much about different things?"),
        QuestionnaireQuestion(id: 2, text: "Over the last two weeks, how often did you have trouble relaxing?"),
        QuestionnaireQuestion(id: 3, text: "Over the last two weeks, how often did you feel restless?"),
        QuestionnaireQuestion(id: 4, text: "Over the last two weeks, how often did you become easily annoyed or irritable?"),
        QuestionnaireQuestion(id: 5, text: "Over the last two weeks, how often did you feel afraid as if something awful might happen?"),
        QuestionnaireQuestion(id: 6, text: "Over the last two weeks, how often did you have difficulty controlling your worry?"),
        QuestionnaireQuestion(id: 7, text: "Over the last two weeks, how often did you feel unable to stop worrying?"),
        QuestionnaireQuestion(id: 8, text: "Over the last two weeks, how stressed did you feel overall?")
    ]
    
    @State private var answers: [Int] = Array(repeating: -1, count: 9)
    @State private var currentQuestionIndex = 0
    @State private var isSubmitting = false

    /// Completion closure provided by the coordinator. When called, the coordinator should switch the app to the main view.
    var onCompleted: () -> Void

    var body: some View {
        NavigationStack {
            VStack {
                // Display the current question.
                QuestionView(
                    question: questions[currentQuestionIndex],
                    answer: $answers[currentQuestionIndex]
                )
                .padding()

                Spacer()
                
                // Button shows "Next" if not on last question,
                // or "Done" on the last question.
                Button(action: {
                    if currentQuestionIndex < questions.count - 1 {
                        currentQuestionIndex += 1
                    } else {
                        submitQuestionnaire()
                    }
                }) {
                    Text(currentQuestionIndex < questions.count - 1 ? "Next" : (isSubmitting ? "Submitting..." : "Done"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .padding()
                .disabled(answers[currentQuestionIndex] == -1 || (currentQuestionIndex == questions.count - 1 && isSubmitting))
            }
            .navigationTitle("Question \(currentQuestionIndex + 1)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func submitQuestionnaire() {
        isSubmitting = true
        print("Submitting questionnaire...")
        let authInfo = AuthInfo(anonymizedID: getAnonymizedID(), accessKey: getAccessKey())
        let requestData = QuestionnaireRequestData(authInfo: authInfo,
                                                   type: "UpdateQuestionaire",
                                                   questions: answers)
        let request = QuestionnaireRequest(requestData: requestData)
        
        CloudManager.shared.sendQuestionnaireData(request: request) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    print("Questionnaire submitted successfully")
                    onCompleted()
                case .failure(let error):
                    print("Failed to submit questionnaire: \(error)")
                }
            }
        }
    }
    
    private func getAnonymizedID() -> String {
        UserDefaults.standard.string(forKey: "AnonymizedID") ?? ""
    }
    
    private func getAccessKey() -> String {
        UserDefaults.standard.string(forKey: "AccessKey") ?? ""
    }
}
