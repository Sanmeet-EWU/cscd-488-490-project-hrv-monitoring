//
//  HRVData.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import Foundation
import CoreData

extension HRVData {
    // Convenience initializer to set up a new HRVData record.
    convenience init(context: NSManagedObjectContext, sdnn: Double, rmssd: Double, pnn50: Double, heartBeats: [Double], creationDate: Date = Date()) {
        self.init(context: context)
        self.id = UUID()
        self.creationDate = creationDate
        self.sdnn = sdnn
        self.rmssd = rmssd
        self.pnn50 = pnn50
        self.heartBeats = heartBeats as NSArray
    }
    
    // Convert this record into the cloud request model.
    func toCloudRequest(authInfo: AddHRVDataRequest.AuthInfo, flags: AddHRVDataRequest.Flags, personalData: AddHRVDataRequest.PersonalData) -> AddHRVDataRequest? {
        guard let creationDate = self.creationDate else { return nil }
        // Build HRVInfo from this HRVData instance.
        let hrvInfo = AddHRVDataRequest.HRVInfo(sdnn: self.sdnn,
                                                rmssd: self.rmssd,
                                                pnn50: self.pnn50,
                                                heartBeats: self.heartBeats as? [Double] ?? [])
        let requestData = AddHRVDataRequest.RequestData(authInfo: authInfo,
                                                        type: "AddData",
                                                        creationDate: creationDate,
                                                        hrvInfo: hrvInfo,
                                                        flags: flags,
                                                        personalData: personalData)
        return AddHRVDataRequest(requestData: requestData)
    }
}
