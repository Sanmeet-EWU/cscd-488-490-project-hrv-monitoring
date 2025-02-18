//
//  LiveHeartRateManager.swift
//  HRVMonitoringWatch Watch App
//
//  Created by Tyler Woody on 2/18/25.
//

import HealthKit
import WatchConnectivity
import SwiftUI

#if os(watchOS)
import HealthKit
#endif

class LiveHeartRateManager: NSObject, ObservableObject {
    static let shared = LiveHeartRateManager()
    
    // Use HealthKitManager for all HealthKit interactions.
    private let healthKitManager = HealthKitManager()
    
    // Track the query's anchor and the active query.
    private var anchor: HKQueryAnchor?
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    @Published var latestHeartRate: Double?
    let hrvCalculator = HRVCalculator()
    
    /// Starts live heart rate updates by requesting HealthKit authorization,
    /// building the query predicate, and executing the anchored query.
    func startLiveUpdates() {
        healthKitManager.requestAuthorization { [weak self] success, error in
            guard let self = self else { return }
            guard success else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Build the query predicate.
            let predicate = self.buildQueryPredicate()
            
            // Create the anchored query.
            let query = self.createAnchoredQuery(with: predicate)
            
            // Execute the query using HealthKitManager's healthStore.
            self.healthKitManager.healthStore.execute(query)
            self.heartRateQuery = query
            print("Started live heart rate updates.")
        }
    }
    
    /// Helper method to build a predicate for the heart rate query.
    /// On watchOS, it filters samples from a specific start date.
    private func buildQueryPredicate() -> NSPredicate? {
        #if os(watchOS)
        // If you need to use an accurate start date from the workout session,
        // consider exposing that from HealthKitManager. Here, we use Date().
        let startDate = Date()
        return HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        #else
        return nil
        #endif
    }
    
    /// Helper method to create an anchored query with the provided predicate.
    private func createAnchoredQuery(with predicate: NSPredicate?) -> HKAnchoredObjectQuery {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            fatalError("Heart rate type is not available.")
        }
        
        // Create the query with an initial results handler.
        let query = HKAnchoredObjectQuery(type: heartRateType,
                                          predicate: predicate,
                                          anchor: self.anchor,
                                          limit: HKObjectQueryNoLimit) { [weak self] (query, samples, deletedObjects, newAnchor, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error in initial live update query: \(error.localizedDescription)")
                return
            }
            self.anchor = newAnchor
            self.processSamples(samples)
        }
        
        // Set the update handler to process new samples in real time.
        query.updateHandler = { [weak self] (query, samples, deletedObjects, newAnchor, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error in live update query update: \(error.localizedDescription)")
                return
            }
            self.anchor = newAnchor
            self.processSamples(samples)
        }
        
        return query
    }
    
    /// Stops the live heart rate updates.
    func stopLiveUpdates() {
        if let query = heartRateQuery {
            healthKitManager.healthStore.stop(query)
            heartRateQuery = nil
            print("Stopped live heart rate updates.")
        }
        #if os(watchOS)
        healthKitManager.stopWorkoutSession()
        #endif
    }
    
    /// Processes the received heart rate samples.
    private func processSamples(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        for sample in samples {
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            print("❤️ Live Heart Rate: \(Int(heartRate)) BPM")
            DispatchQueue.main.async {
                self.latestHeartRate = heartRate
                self.hrvCalculator.addBeat(heartRate: heartRate, at: Date())
                // Evaluate HRV and detect events.
                EventDetectionManager.shared.evaluateHRV(using: self.hrvCalculator)
                // Send the heart rate data to the paired device.
                DataSender.shared.sendHeartRateData(heartRate: heartRate)
            }
        }
    }
}
