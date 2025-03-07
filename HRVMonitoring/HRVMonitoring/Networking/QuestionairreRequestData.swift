//
//  QuestionairreRequestData.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/3/25.
//

import Foundation

struct AuthInfo: Codable {
    let anonymizedID: String
    let accessKey: String
}

struct QuestionnaireRequestData: Codable {
    let authInfo: AuthInfo
    let type: String  // "UpdateQuestionaire"
    let questions: [Int]
}

struct QuestionnaireRequest: Codable {
    let requestData: QuestionnaireRequestData
}
