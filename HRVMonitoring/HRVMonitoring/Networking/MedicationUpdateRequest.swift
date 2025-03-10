//
//  MedicationUpdateRequest.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/9/25.
//

import Foundation

struct MedicationUpdateRequest: Codable {
    struct RequestData: Codable {
        let authInfo: AuthInfo
        let type: String
        let medications: [String]
        
        enum CodingKeys: String, CodingKey {
            case authInfo = "AuthInfo"
            case type = "Type"
            case medications = "Medications"
        }
    }
    
    let requestData: RequestData
    
    enum OuterKeys: String, CodingKey {
        case body
    }
    
    enum BodyKeys: String, CodingKey {
        case RequestData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OuterKeys.self)
        let bodyContainer = try container.nestedContainer(keyedBy: BodyKeys.self, forKey: .body)
        requestData = try bodyContainer.decode(RequestData.self, forKey: .RequestData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OuterKeys.self)
        var bodyContainer = container.nestedContainer(keyedBy: BodyKeys.self, forKey: .body)
        try bodyContainer.encode(requestData, forKey: .RequestData)
    }
}
