//
//  MockHeartRateGenerator.swift
//  HRVMonitoringWatch Watch App
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import WatchConnectivity
import SwiftUI

class MockHeartRateGenerator: ObservableObject {
    static let shared = MockHeartRateGenerator()
    
    @Published var currentHeartRate: Double?
    // Removed local events storage
    @Published var showEventList: Bool = false
    
    private var heartRateTimer: Timer?
    private var baseHeartRate: Double = 75.0
    private var isIncreasing = true
    
    private let hrvCalculator = HRVCalculator()
    private let rmssdThreshold: Double = 30.0 // Adjust threshold as needed
    
    // No local activeEvent
    
    func startStreamingHeartRate() {
        // Only start streaming if we're in mock mode.
        guard DataModeManager.shared.isMockMode else {
            print("Not in mock mode – not starting the mock generator.")
            return
        }
        guard heartRateTimer == nil else { return }
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.generateAndSendHeartRate()
        }
    }
    
    func stopStreamingHeartRate() {
        heartRateTimer?.invalidate()
        heartRateTimer = nil
    }
    
    private func generateAndSendHeartRate() {
        // Double-check we're in mock mode.
        guard DataModeManager.shared.isMockMode else { return }
        
        let variability = Double.random(in: -5...5)
        if isIncreasing {
            baseHeartRate += 1.0 + variability
            if baseHeartRate > 120 { isIncreasing = false }
        } else {
            baseHeartRate -= 1.0 + variability
            if baseHeartRate < 40 { isIncreasing = true }
        }
        
        let realisticHeartRate = max(40, min(120, baseHeartRate))
        currentHeartRate = realisticHeartRate
        
        hrvCalculator.addBeat(heartRate: realisticHeartRate, at: Date())
        
        print("Current RMSSD: \(hrvCalculator.rmssd ?? 0)")
        
        // Call the centralized event detection.
        EventDetectionManager.shared.evaluateHRV(using: hrvCalculator)
        
        DataSender.shared.sendHeartRateData(heartRate: realisticHeartRate)
    }
}

extension MockHeartRateGenerator {
    func handleUserResponse(event: Event, isConfirmed: Bool) {
        // Update the shared event manager.
        if let index = EventDetectionManager.shared.events.firstIndex(where: { $0.id == event.id }) {
            EventDetectionManager.shared.events[index].isConfirmed = isConfirmed
            EventDetectionManager.shared.events.remove(at: index)
        }
        DataSender.shared.sendUserResponse(event: event, isConfirmed: isConfirmed)
    }
}

