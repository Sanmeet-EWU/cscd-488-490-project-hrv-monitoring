//
//  AddHRVDataRequest.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import Foundation

struct AddHRVDataRequest: Codable {
    struct AuthInfo: Codable {
        let anonymizedID: String
        let accessKey: String
    }
    struct HRVInfo: Codable {
        let sdnn: Double
        let rmssd: Double
        let pnn50: Double
        let heartBeats: [Double]
    }
    struct Flags: Codable {
        let userFlagged: Bool
        let programFlagged: Bool
    }
    struct Injury: Codable {
        let type: String
        let date: Date
    }
    struct PersonalData: Codable {
        let age: Int
        let bmi: Double
        let hospitalName: String
        let injury: Injury
    }
    struct RequestData: Codable {
        let authInfo: AuthInfo
        let type: String  // e.g., "AddData"
        let creationDate: Date
        let hrvInfo: HRVInfo
        let flags: Flags
        let personalData: PersonalData
    }
    
    let requestData: RequestData
}

// A helper function that builds the HRVInfo portion from your HRVCalculator:
func buildHRVInfo(from calculator: HRVCalculator) -> AddHRVDataRequest.HRVInfo? {
    guard let sdnn = calculator.sdnn,
          let rmssd = calculator.rmssd,
          let pnn50 = calculator.pnn50 else {
        return nil
    }
    
    let heartBeats = calculator.beats.map {$0.ibi}
    
    return AddHRVDataRequest.HRVInfo(sdnn: sdnn,
                                     rmssd: rmssd,
                                     pnn50: pnn50,
                                     heartBeats: heartBeats)
}

