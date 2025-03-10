//
//  EventDetectionManager.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import Foundation
import Combine

class EventDetectionManager: ObservableObject {
    static let shared = EventDetectionManager()
    
    @Published var activeEvent: Event?
    @Published var events: [Event] = []
    
    // The RMSSD threshold to trigger events.
    let rmssdThreshold: Double = ProjectConfig.active.RMSSD_THRESHOLD
    
    /// Evaluate HRV values and start or end an event accordingly.
    func evaluateHRV(using hrvCalculator: HRVCalculator) {
        // Only evaluate if there are at least 5 beats and RMSSD is non-zero.
        guard hrvCalculator.beats.count >= 5,
              let currentRMSSD = hrvCalculator.rmssd,
              currentRMSSD > 0 else {
            return
        }
        
        if currentRMSSD < rmssdThreshold, activeEvent == nil {
            startEvent()
        } else if currentRMSSD >= rmssdThreshold, let event = activeEvent {
            endEvent(event: event)
        }
    }
    
    public func newEvent() {
        self.startEvent()
        self.endEvent(event:self.activeEvent!)
    }

    
    private func startEvent() {
        let newEvent = Event(id: UUID(), startTime: Date(), endTime: Date(), isConfirmed: nil)
        activeEvent = newEvent
        print("New event started: \(newEvent.id)")
        // Optionally, send an event-start message.
    }
    
    private func endEvent(event: Event) {
        guard let active = activeEvent, active.id == event.id else { return }
        var endedEvent = active
        endedEvent.endTime = Date()
        events.append(endedEvent)
        activeEvent = nil
        print("Event ended: \(endedEvent.id)")
        DataSender.shared.sendEventEndData(event: endedEvent)
    }
    
    /// Called when a connectivity message indicates the event was handled.
    func handleEventHandled(eventID: UUID) {
        events.removeAll { $0.id == eventID }
        if let active = activeEvent, active.id == eventID {
            activeEvent = nil
        }
        print("Handled event \(eventID)")
    }
}
