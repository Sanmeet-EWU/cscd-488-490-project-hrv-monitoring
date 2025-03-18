//
//  QuestionairreQuestion.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/3/25.
//

import Foundation

/// A model representing one questionnaire question.
struct QuestionnaireQuestion: Identifiable, Codable {
    let id: Int
    let text: String
}
