//
//  HRVCalculator.swift
//  HRVMonitoring
//
//  Created by Tyler Woody Austin Harrison on 2/18/25.
//

import Foundation
import Combine
import Collections

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
    var windowSize: TimeInterval = ProjectConfig.active.HRV_WINDOW_SIZE
    private var lastSaved: Date?

    @Published private(set) var beats: Deque<Beat> = []
    @Published var latestRMSSD: Double? = nil
    @Published var latestSDNN: Double? = nil
    @Published var latestPNN50: Double? = nil
    
    /// The collected beats within the current window.
//    @Published private(set) var beats: [Beat] = []
    

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
    
    func addBeat(heartRate: Double, at timestamp: Date = Date()) {
        let newBeat = Beat(timestamp: timestamp, heartRate: heartRate)
        beats.append(newBeat)
        print("Added beat at \(timestamp)")
        
        self.latestRMSSD = rmssd
        self.latestSDNN = sdnn
        self.latestPNN50 = pnn50
    
        maintainRollingWindow(currentTime: timestamp)
        periodicallySaveAndSendData(currentTime: timestamp)
    }

    private func maintainRollingWindow(currentTime: Date) {
        while let firstBeat = beats.first,
              currentTime.timeIntervalSince(firstBeat.timestamp) > windowSize {
            beats.removeFirst()
        }
        print("Window maintained. Current beat count: \(beats.count)")
    }

    private func periodicallySaveAndSendData(currentTime: Date) {
        guard let lastSaved = lastSaved else {
            self.lastSaved = currentTime
            return
        }

        if currentTime.timeIntervalSince(lastSaved) >= windowSize {
            saveAndSendData()
            self.lastSaved = currentTime
        }
    }

    private func saveAndSendData() {
        guard !beats.isEmpty else {
            print("No data to save.")
            return
        }
        
        self.latestRMSSD = rmssd
        self.latestSDNN = sdnn
        self.latestPNN50 = pnn50
        
        HRVDataManager.shared.createHRVData(
            heartBeats: beats.map { $0.heartRate },
            pnn50: self.latestPNN50 ?? 0.0,
            rmssd: self.latestRMSSD ?? 0.0,
            sdnn: self.latestSDNN ?? 0.0
        )
        
        #if os(iOS)
        HRVLiveDataSender.shared.sendLiveHRVData(using: self, programTriggered: false)
        #endif
    }
}
