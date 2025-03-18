//
//  CreateUserRequest.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/8/25.
//

import Foundation

struct CreateUserRequest: Codable {
    struct AuthInfo: Codable {
        let anonymizedID: String
        let accessKey: String

        enum CodingKeys: String, CodingKey {
            case anonymizedID = "AnonymizedID"
            case accessKey = "AccessKey"
        }
    }

    struct RequestData: Codable {
        let authInfo: AuthInfo
        let type: String  // "CreateUser"

        enum CodingKeys: String, CodingKey {
            case authInfo = "AuthInfo"
            case type = "Type"
        }
    }

    struct Body: Codable {
        let requestData: RequestData

        enum CodingKeys: String, CodingKey {
            case requestData = "RequestData"
        }
    }

    let body: Body
}
