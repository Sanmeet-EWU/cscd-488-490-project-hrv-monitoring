//
//  PersistenceController.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "HRVDataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // Convenience method to save the context.
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Proper error handling should be done here.
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
}

