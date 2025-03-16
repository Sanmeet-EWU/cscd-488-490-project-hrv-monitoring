//
//  HRVLiveDataSender.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 3/11/25.
//

import Foundation
import os.log

class HRVLiveDataSender {
    static let shared = HRVLiveDataSender()
    
    func sendLiveHRVData(using hrvCalculator: HRVCalculator, programTriggered: Bool) {
        guard CloudManager.shared.canSendData() else {
            os_log("HRVLiveDataSender: Data sending blocked due to lack of user consent.", log: OSLog.default, type: .info)
            return
        }

        guard let hrvInfo = buildHRVInfo(from: hrvCalculator) else {
            os_log("HRVLiveDataSender: HRV metrics are not available yet.", log: OSLog.default, type: .info)
            return
        }

        os_log("HRVLiveDataSender: HRV metrics: %{public}@", log: OSLog.default, type: .info, String(describing: hrvInfo))

        guard let anonymizedID = UserDefaults.standard.string(forKey: "AnonymizedID"),
              let accessKey = UserDefaults.standard.string(forKey: "AccessKey") else {
            os_log("HRVLiveDataSender: Missing authentication credentials.", log: OSLog.default, type: .error)
            return
        }

        let authInfo = AddHRVDataRequest.AuthInfo(anonymizedID: anonymizedID, accessKey: accessKey)

        let hospitalName = UserDefaults.standard.string(forKey: "HospitalName") ?? "Default Hospital"
        let age = UserDefaults.standard.integer(forKey: "Age")
        let bmi = UserDefaults.standard.double(forKey: "BMI")
        let gender = UserDefaults.standard.string(forKey: "Gender")
        let injuryType = UserDefaults.standard.string(forKey: "InjuryType") ?? "None"
        let injuryDate = UserDefaults.standard.object(forKey: "InjuryDate") as? Date ?? Date()

        let personalData = AddHRVDataRequest.PersonalData(
            age: age,
            bmi: bmi,
            gender: gender,
            hospitalName: hospitalName,
            injury: AddHRVDataRequest.Injury(type: injuryType, date: injuryDate)
        )

        let flags = AddHRVDataRequest.Flags(userFlagged: false, programFlagged: programTriggered)

        let requestData = AddHRVDataRequest.RequestData(
            authInfo: authInfo,
            type: "AddData",
            creationDate: Date(),
            hrvInfo: hrvInfo,
            flags: flags,
            personalData: personalData
        )

        let liveHRVRequest = AddHRVDataRequest(requestData: requestData)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try encoder.encode(liveHRVRequest)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                os_log("HRVLiveDataSender - Final HRV JSON being sent: %{public}@", log: OSLog.default, type: .info, jsonString)
            }
        } catch {
            os_log("HRVLiveDataSender: Failed to encode HRVLiveDataRequest: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
        }

        CloudManager.shared.sendHRVData(request: liveHRVRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let responseCode):
                    os_log("HRVLiveDataSender: Live HRV data sent successfully. Response code: %d", log: OSLog.default, type: .info, responseCode)
                case .failure(let error):
                    os_log("HRVLiveDataSender: Failed to send live HRV data: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
                }
            }
        }
    }
    func logToFile(_ message: String) {
        let logMessage = "\(Date()): \(message)\n"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("simulator_log.txt")
        
        if let handle = try? FileHandle(forWritingTo: fileURL) {
            handle.seekToEndOfFile()
            handle.write(logMessage.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? logMessage.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
}
