//
//  HRVDataManager.swift
//  HRVMonitoring
//
//  Created by Austin Harrison on 3/3/25.
//

import CoreData

class HRVDataManager {
    static let shared = HRVDataManager()
    private let context = PersistenceController.shared.container.viewContext
    
    // Insert a new record.
    func createHRVData(heartBeats: [Double], pnn50: Double, rmssd: Double, sdnn: Double) {
        let newData = HRVDataModel(context: context)
        newData.id = UUID()
        newData.creationDate = Date()
        newData.heartBeats = heartBeats as NSArray
        newData.pnn50 = pnn50
        newData.rmssd = rmssd
        newData.sdnn = sdnn
        
        saveContext()
    }
    
    // Fetch records.
    func fetchHRVData() -> [HRVDataModel] {
        let request: NSFetchRequest<HRVDataModel> = HRVDataModel.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print("Error fetching HRV data: \(error.localizedDescription)")
            return []
        }
    }
    
    // Delete a record.
    func deleteHRVData(_ data: HRVDataModel) {
        context.delete(data)
        saveContext()
    }
    
    // Save changes.
    private func saveContext() {
        PersistenceController.shared.saveContext()
    }
}

