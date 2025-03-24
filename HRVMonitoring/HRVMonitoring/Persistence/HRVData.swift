//
//  HRVData.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import Foundation
import CoreData

// MARK: - HRVdata DTO

struct HRVdata: Codable {
    let id: UUID
    let heartBeats: [Double]
    let pnn50: Double
    let rmssd: Double
    let sdnn: Double
}

// MARK: - Conversion Helpers

extension HRVdata {
    // Initialize an HRVdata instance from a Core Data HRVDataModel.
    init?(from model: HRVDataModel) {
        guard let id = model.id,
              let heartBeats = model.heartBeats else {
            return nil
        }
        self.id = id
        self.heartBeats = heartBeats as! [Double]
        self.pnn50 = model.pnn50
        self.rmssd = model.rmssd
        self.sdnn = model.sdnn
    }
    
    // Convert the HRVdata instance back into a HRVDataModel using the provided NSManagedObjectContext.
    func toCoreDataModel(in context: NSManagedObjectContext) -> HRVDataModel {
        let model = HRVDataModel(context: context)
        model.id = self.id
        model.heartBeats = self.heartBeats as NSArray
        model.pnn50 = self.pnn50
        model.rmssd = self.rmssd
        model.sdnn = self.sdnn
        return model
    }
}
