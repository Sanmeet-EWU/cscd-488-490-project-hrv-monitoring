//
//  QuestionView.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/3/25.
//

import SwiftUI

struct QuestionView: View {
    let question: QuestionnaireQuestion
    @Binding var answer: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question.text)
                .font(.headline)
                .padding(.bottom, 20)
            ForEach(0..<5, id: \.self) { index in
                Button(action: {
                    answer = index
                }) {
                    HStack {
                        Image(systemName: answer == index ? "largecircle.fill.circle" : "circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text(optionLabel(for: index))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(answer == index ? Color.blue.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                }
                .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
    }
    
    private func optionLabel(for index: Int) -> String {
        switch index {
        case 0: return "Not at all"
        case 1: return "Several days"
        case 2: return "More than half the days"
        case 3: return "Nearly every day"
        case 4: return "Always"
        default: return ""
        }
    }
}
