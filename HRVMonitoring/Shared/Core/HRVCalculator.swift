//
//  HRVCalculator.swift
//  HRVMonitoring
//
//  Created by Tyler Woody Austin Harrison on 2/18/25.
//

import Foundation
import Combine

/// Represents a single heart beat with its timestamp and heart rate.
struct Beat {
    let timestamp: Date
    let heartRate: Double
    
    /// Calculate IBI (Inter-Beat Interval) in milliseconds.
    /// (IBI = 60000 / BPM)
    var ibi: Double {
        return 60000.0 / heartRate
    }
}

/// HRVCalculator maintains a rolling window of beats (default 5 minutes)
/// and computes HRV metrics such as RMSSD, SDNN, and pNN50.
class HRVCalculator: ObservableObject {
    /// Window size in seconds. Default is 5 minutes (300 seconds).
    var windowSize: TimeInterval = 30
    
    /// The collected beats within the current window.
    @Published private(set) var beats: [Beat] = []
    
    /// Computed RMSSD (Root Mean Square of Successive Differences)
    /// Requires at least two beats.
    var rmssd: Double? {
        let ibis = beats.map { $0.ibi }
        guard ibis.count >= 2 else { return nil }
        
        var squaredDiffs: [Double] = []
        for i in 1..<ibis.count {
            let diff = ibis[i] - ibis[i - 1]
            squaredDiffs.append(diff * diff)
        }
        
        let meanSquaredDiff = squaredDiffs.reduce(0, +) / Double(squaredDiffs.count)
        return sqrt(meanSquaredDiff)
    }
    
    /// Computed SDNN (Standard Deviation of NN intervals)
    var sdnn: Double? {
        let ibis = beats.map { $0.ibi }
        guard !ibis.isEmpty else { return nil }
        
        let mean = ibis.reduce(0, +) / Double(ibis.count)
        let variance = ibis.reduce(0) { $0 + pow($1 - mean, 2) } / Double(ibis.count)
        return sqrt(variance)
    }
    
    /// pnn50 is the percentage of successive differences greater than 50 ms.
    var pnn50: Double? {
        let ibis = beats.map { $0.ibi }
        guard ibis.count > 1 else { return nil }
        
        let count = (1..<ibis.count).reduce(0) { sum, i in
            let diff = abs(ibis[i] - ibis[i - 1])
            return sum + (diff > 50 ? 1 : 0)
        }
        
        return (Double(count) / Double(ibis.count - 1)) * 100.0
    }
    
    // Adds a new beat
    // In a fixed window, we simply accumulate beats until the window duration is reached.
    func addBeat(heartRate: Double, at timestamp: Date = Date()) {
        let newBeat = Beat(timestamp: timestamp, heartRate: heartRate)
        beats.append(newBeat)
        print("Added a beat at \(timestamp)")
        checkWindowAndCreateRecord()
    }
    
    // Checks if the fixed window duration has been reached
    // If so, computes metrics, cretaes a record, and resets the window
    private func checkWindowAndCreateRecord() {
        guard let firstBeat = beats.first, let lastBeat = beats.last else {
            print("No beats available to evaluate window.")
            return
        }
        
        let windowDuration = lastBeat.timestamp.timeIntervalSince(firstBeat.timestamp)
        print("Current window duration: \(windowDuration) seconds (Window size required: \(windowSize) seconds)")
        
        if windowDuration >= windowSize {
            let heartRates = beats.map { $0.heartRate }
            let computedRMSSD = self.rmssd ?? 0.0
            let computedSDNN = self.sdnn ?? 0.0
            let computedPNN50 = self.pnn50 ?? 0.0
            
            // Create a record using HRVDataManager.
            HRVDataManager.shared.createHRVData(
                heartBeats: heartRates,
                pnn50: computedPNN50,
                rmssd: computedRMSSD,
                sdnn: computedSDNN
            )
            
            print("Data saved at \(Date()): Heart rates: \(heartRates)")
            
            // Fetch the last saved record and print it.
            let records = HRVDataManager.shared.fetchHRVData()
            if let lastRecord = records.last {
                print("Last record: \(lastRecord)")
            } else {
                print("No records found.")
            }
            
            // Reset the fixed window by clearing all beats.
            beats.removeAll()
        } else {
            print("Window not reached yet. Current window duration: \(windowDuration) seconds")
        }
    }
}
