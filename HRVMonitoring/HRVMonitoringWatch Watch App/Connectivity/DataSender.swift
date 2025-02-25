//
//  DataSender.swift
//  HRVMonitoringWatch Watch App
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import WatchConnectivity
import SwiftUI

class DataSender: ObservableObject {
    static let shared = DataSender()
    
    // Computed property to get the default session.
    private var session: WCSession {
        let session = WCSession.default
        print("WCSession activation state: \(session.activationState.rawValue)")
        return session
    }
    
    // MARK: - Data Sending Methods
    
    func sendHeartRateData(heartRate: Double) {
        guard session.isReachable else {
            print("📡 ❌ iPhone is not reachable. Cannot send heart rate data.")
            return
        }
        let data: [String: Any] = [
            "HeartRate": heartRate,
            "Timestamp": Date().timeIntervalSince1970
        ]
        session.sendMessage(data, replyHandler: nil) { error in
            print("📡 ❌ Failed to send heart rate data: \(error.localizedDescription)")
        }
        print("📡 ✅ Sent heart rate: \(heartRate) BPM to iPhone")
    }
    
    func sendEventEndData(event: Event) {
        guard session.isReachable else {
            print("iPhone is not reachable")
            return
        }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let eventData: [String: Any] = [
            "Event": "EventEnded",
            "EventID": event.id.uuidString,
            "StartTime": isoFormatter.string(from: event.startTime),
            "EndTime": isoFormatter.string(from: event.endTime)
        ]
        session.sendMessage(eventData, replyHandler: nil) { error in
            print("Failed to send event end data: \(error.localizedDescription)")
        }
        print("Sent event: \(event.id)")
    }
    
    func sendUserResponse(event: Event, isConfirmed: Bool) {
        guard session.isReachable else {
            print("iPhone is not reachable")
            return
        }
        let response: [String: Any] = [
            "Event": "EventHandled",
            "EventID": event.id.uuidString,
            "IsConfirmed": isConfirmed
        ]
        session.sendMessage(response, replyHandler: nil) { error in
            print("Failed to send EventHandled message: \(error.localizedDescription)")
        }
        print("Sent event confirmation for \(event.id)")
    }
}

