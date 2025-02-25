//
//  WatchConnectivityHandler.swift
//  HRVMonitoringWatch Watch App
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import WatchConnectivity
import SwiftUI

class WatchConnectivityHandler: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityHandler()
    
    private override init() {
        super.init()
        activateSession()
    }
    
    private func activateSession() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported on this device")
            return
        }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    // MARK: - WCSessionDelegate Methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            // Handle a mode change message:
            if let mode = message["isMockMode"] as? Bool {
                print("Received mode change: \(mode ? "Mock" : "Live")")
                DataModeManager.shared.isMockMode = mode
            }
            
            // Handle an event-handled message:
            if let eventAction = message["Event"] as? String, eventAction == "EventHandled",
               let eventID = message["EventID"] as? String,
               let uuid = UUID(uuidString: eventID) {
                EventDetectionManager.shared.handleEventHandled(eventID: uuid)
                print("Event \(uuid) handled on watch")
            }
        }
    }
}
