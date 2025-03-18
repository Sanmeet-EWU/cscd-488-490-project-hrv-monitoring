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

    enum CodingKeys: String, CodingKey {
        case anonymizedID = "AnonymizedID"
        case accessKey = "AccessKey"
    }
}

struct QuestionnaireRequestData: Codable {
    let authInfo: AuthInfo
    let type: String  // "UpdateQuestionaire"
    let questions: [Int]

    enum CodingKeys: String, CodingKey {
        case authInfo = "AuthInfo"
        case type = "Type"
        case questions = "Questions"
    }
}


struct QuestionnaireRequest: Codable {
    let requestData: QuestionnaireRequestData

    // New convenience initializer for direct instantiation.
    init(requestData: QuestionnaireRequestData) {
        self.requestData = requestData
    }

    enum OuterKeys: String, CodingKey {
        case body
    }

    enum BodyKeys: String, CodingKey {
        case RequestData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OuterKeys.self)
        let bodyContainer = try container.nestedContainer(keyedBy: BodyKeys.self, forKey: .body)
        requestData = try bodyContainer.decode(QuestionnaireRequestData.self, forKey: .RequestData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OuterKeys.self)
        var bodyContainer = container.nestedContainer(keyedBy: BodyKeys.self, forKey: .body)
        try bodyContainer.encode(requestData, forKey: .RequestData)
    }
}


