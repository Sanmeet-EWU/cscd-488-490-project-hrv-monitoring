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
        
        enum CodingKeys: String, CodingKey {
            case anonymizedID = "AnonymizedID"
            case accessKey = "AccessKey"
        }
    }
    
    struct HRVInfo: Codable {
        let sdnn: Double
        let rmssd: Double
        let pnn50: Double
        let heartBeats: [Double]
        
        enum CodingKeys: String, CodingKey {
            case sdnn = "SDNN"
            case rmssd = "RMSSD"
            case pnn50 = "PNN50"
            case heartBeats = "HeartBeats"
        }
        
        // Custom encoding: Convert heartBeats to an array of Ints.
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(sdnn, forKey: .sdnn)
            try container.encode(rmssd, forKey: .rmssd)
            try container.encode(pnn50, forKey: .pnn50)
            let intHeartBeats = heartBeats.map { Int($0.rounded()) }
            try container.encode(intHeartBeats, forKey: .heartBeats)
        }
    }
    
    struct Flags: Codable {
        let userFlagged: Bool
        let programFlagged: Bool
        
        enum CodingKeys: String, CodingKey {
            case userFlagged = "UserFlagged"
            case programFlagged = "ProgramFlagged"
        }
    }
    
    struct Injury: Codable {
        let type: String
        let date: Date
        
        enum CodingKeys: String, CodingKey {
            case type = "Type"
            case date = "Date"
        }
        
        init(type: String, date: Date) {
            self.type = type
            self.date = date
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            let dateString = try container.decode(String.self, forKey: .date)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"  // Expecting a regular date format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            guard let parsedDate = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(forKey: .date,
                                                       in: container,
                                                       debugDescription: "Date string does not match format yyyy-MM-dd")
            }
            date = parsedDate
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: date)
            
            try container.encode(dateString, forKey: .date)
        }
    }
    
    struct PersonalData: Codable {
        let age: Int
        let bmi: Double
        let gender: String?
        let hospitalName: String
        let injury: Injury
        
        enum CodingKeys: String, CodingKey {
            case age = "Age"
            case bmi = "BMI"
            case gender = "Gender"
            case hospitalName = "HospitalName"
            case injury = "Injury"
        }
    }
    
    struct RequestData: Codable {
        let authInfo: AuthInfo
        let type: String  // e.g., "AddData"
        let creationDate: Date?  // Optional if not included
        let hrvInfo: HRVInfo
        let flags: Flags
        let personalData: PersonalData
        
        enum CodingKeys: String, CodingKey {
            case authInfo = "AuthInfo"
            case type = "Type"
            case creationDate = "CreationDate"
            case hrvInfo = "HRVInfo"
            case flags = "Flags"
            case personalData = "PersonalData"
        }
    }
    
    let requestData: RequestData
    
    // MARK: - Custom Decoding/Encoding to support the "body" wrapper
    enum OuterKeys: String, CodingKey {
        case body
    }
    
    enum BodyKeys: String, CodingKey {
        case RequestData
    }
    init(requestData: RequestData) {
        self.requestData = requestData
    }
    
    init(from decoder: Decoder) throws {
        let outerContainer = try decoder.container(keyedBy: OuterKeys.self)
        let bodyContainer = try outerContainer.nestedContainer(keyedBy: BodyKeys.self, forKey: .body)
        requestData = try bodyContainer.decode(RequestData.self, forKey: .RequestData)
    }
    
    func encode(to encoder: Encoder) throws {
        var outerContainer = encoder.container(keyedBy: OuterKeys.self)
        var bodyContainer = outerContainer.nestedContainer(keyedBy: BodyKeys.self, forKey: .body)
        try bodyContainer.encode(requestData, forKey: .RequestData)
    }
}

// A helper function that builds the HRVInfo portion from your HRVCalculator:
func buildHRVInfo(from calculator: HRVCalculator) -> AddHRVDataRequest.HRVInfo? {
    guard let sdnn = calculator.sdnn,
          let rmssd = calculator.rmssd,
          let pnn50 = calculator.pnn50 else {
        return nil
    }
    
    let heartBeats = calculator.beats.map { $0.ibi }
    
    return AddHRVDataRequest.HRVInfo(sdnn: sdnn,
                                     rmssd: rmssd,
                                     pnn50: pnn50,
                                     heartBeats: heartBeats)
}
