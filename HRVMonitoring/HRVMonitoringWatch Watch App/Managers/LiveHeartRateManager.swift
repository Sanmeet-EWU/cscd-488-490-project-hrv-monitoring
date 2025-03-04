//
//  PersistenceController.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import HealthKit
import WatchConnectivity
import SwiftUI

import HealthKit

class LiveHeartRateManager: NSObject, ObservableObject {
    
    static let shared = LiveHeartRateManager()
    
    // Use HealthKitManager for all HealthKit interactions.
    private let healthKitManager = HealthKitManager()
    
    // Track the query's anchor and the active query.
    private var anchor: HKQueryAnchor?
    
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    @Published var latestHeartRate: Double?
    
    let hrvCalculator = HRVCalculator()
    
    // Starts live heart rate updates by requesting HealthKit authorization,
    // building the query, and executing the anchored query.
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
    
    // Helper method to build a predicate for the heart rate query.
    // On WatchOS,it filters samples from a specific start date.
    private func buildQueryPredicate() -> NSPredicate? {
        // If you need to use an accurate start date from the workout session,
        // consider exposing that from HealthKitManager. Here, we use Date().
        let startDate = Date()
        return HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
    }
    
    // Helper method to create an anchored query with the predicate.
    // Role of an Anchor - The anchor (an instance of HKQueryAnchor) records the
    // position in the HealthKit data stream corresponding to the most recent sample
    // your app has processed.
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
    
    // Stops the live heart rate updates.
    func stopLiveUpdates() {
        if let query = heartRateQuery {
            healthKitManager.healthStore.stop(query)
            heartRateQuery = nil
            print("Stopped live heart rate updates.")
        }
        healthKitManager.stopWorkoutSession()
    }
    
    // Processes the recieved heart rate samples.
    private func processSamples(_ samples: [HKSample]?) {
        // 1. Type Casting:
        guard let samples = samples as? [HKQuantitySample] else { return }
        
        // 2. Iterate over each sample:
        for sample in samples {
            // 3. Extract Heart Rate Value:
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            print("❤️ Live Heart Rate: \(Int(heartRate)) BPM")
            
            // Extract the timestamp directly from the HealthKit sample.
            let sampleTimestamp = sample.startDate
            
            // 4. Update on the Main Thread:
            DispatchQueue.main.async {
                self.latestHeartRate = heartRate
                
                // Use the HealthKit timestamp for the HRV calculation.
//                self.hrvCalculator.addBeat(heartRate: heartRate, at: sampleTimestamp)
                EventDetectionManager.shared.evaluateHRV(using: self.hrvCalculator)
                
                // Create a HeartRateSample object with the data from HealthKit.
                let hrSample = HeartRateSample(heartRate: heartRate, timestamp: sampleTimestamp)
                self.processHeartRate(hrSample)
            }
        }
    }
    private func processHeartRate(_ sample: HeartRateSample) {
        if WCSession.default.isReachable {
            // Flush any buffered samples first.
            WatchDataBuffer.shared.flushBuffer()
            // Send the current sample (including the original timestamp).
            DataSender.shared.sendHeartRateData(sample: sample)
        } else {
            // Buffer the sample for later.
            WatchDataBuffer.shared.addSample(sample)
        }
    }
}

