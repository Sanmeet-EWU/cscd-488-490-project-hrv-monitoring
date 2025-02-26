//
//  PhoneConnectivityManager.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import WatchConnectivity
import SwiftUI

class PhoneConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneConnectivityManager()

    @Published var latestHeartRate: Double? = nil
    @Published var isPromptVisible: Bool = false {
        didSet { print("isPromptVisible updated: \(isPromptVisible)") }
    }
    @Published var eventMessage: String? = nil
    @Published var hrvCalculator = HRVCalculator()

    private override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else {
            print("❌ PhoneWCSession is NOT supported on this device")
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("📡 PhoneWCSession State: \(session.activationState.rawValue)")
    }

    // MARK: - WCSessionDelegate Methods

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("iOS PhoneWCSession activation error: \(error.localizedDescription)")
        } else {
            print("iOS PhoneWCSession activated with state: \(activationState.rawValue)")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            print("iOS received message: \(message)")
            
            // Handle heart rate data from Watch
            if let heartRate = message["HeartRate"] as? Double,
               let timestampInterval = message["Timestamp"] as? Double {
                let timestamp = Date(timeIntervalSince1970: timestampInterval)
                self.latestHeartRate = heartRate
                self.hrvCalculator.addBeat(heartRate: heartRate, at: timestamp)
                print("Received heart rate from Watch: \(heartRate) BPM at \(timestamp)")
            }
            
            // Handle event ended message from Watch
            if let eventAction = message["Event"] as? String, eventAction == "EventEnded" {
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let eventIDString = message["EventID"] as? String,
                   let startTimeString = message["StartTime"] as? String,
                   let endTimeString = message["EndTime"] as? String {
                    print("Received event strings - EventID: \(eventIDString), StartTime: \(startTimeString), EndTime: \(endTimeString)")
                    if let eventID = UUID(uuidString: eventIDString),
                       let startTime = isoFormatter.date(from: startTimeString),
                       let endTime = isoFormatter.date(from: endTimeString) {
                        let event = Event(id: eventID, startTime: startTime, endTime: endTime, isConfirmed: nil)
                        EventDetectionManager.shared.events.append(event)
                        print("Received event from Watch: \(eventID)")
                    } else {
                        print("Date parsing failed for event message: \(message)")
                    }
                } else {
                    print("Failed to parse event data from message: \(message)")
                }
            }
            
            // Handle event handled message from Watch (Confirm/Dismiss)
            if let eventAction = message["Event"] as? String, eventAction == "EventHandled" {
                if let eventIDString = message["EventID"] as? String,
                   let eventID = UUID(uuidString: eventIDString) {
                    EventDetectionManager.shared.handleEventHandled(eventID: eventID)
                    print("iOS side: Event \(eventID) was handled on Watch")
                } else {
                    print("Failed to parse eventID from EventHandled message: \(message)")
                }
            }
        }
    }

    func sendUserResponse(event: Event, isConfirmed: Bool) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        let response: [String: Any] = [
            "Event": "EventHandled",
            "EventID": event.id.uuidString,
            "IsConfirmed": isConfirmed
        ]
        WCSession.default.sendMessage(response, replyHandler: nil) { error in
            print("Failed to send user response to watch: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            EventDetectionManager.shared.events.removeAll { $0.id == event.id }
            print("Event \(event.id) \(isConfirmed ? "confirmed" : "dismissed") and removed.")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        WCSession.default.activate()
    }
    
    func sendModeChange(isMockMode: Bool) {
        guard WCSession.default.isReachable else {
            print("Watch is not reachable")
            return
        }
        let modeMessage: [String: Any] = ["isMockMode": isMockMode]
        WCSession.default.sendMessage(modeMessage, replyHandler: nil) { error in
            print("Failed to send mode change: \(error.localizedDescription)")
        }
        print("Sent mode change: \(isMockMode ? "Mock" : "Live")")
    }
}
