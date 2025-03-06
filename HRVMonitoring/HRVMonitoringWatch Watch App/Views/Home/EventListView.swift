//
//  EventListView.swift
//  HRVMonitoringWatch Watch App
//
//  Created by Tyler Woody on 2/18/25.
//

import SwiftUI

struct EventListView: View {
    @EnvironmentObject var eventDetector: EventDetectionManager

    var body: some View {
        NavigationView {
            List {
                ForEach(eventDetector.events) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event ID: \(event.id.uuidString.prefix(8))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Start: \(event.startTime.formatted())")
                            .font(.subheadline)
                        Text("End: \(event.endTime.formatted())")
                            .font(.subheadline)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                // Send the user response and update the shared event manager.
                                DataSender.shared.sendUserResponse(event: event, isConfirmed: true)
                                eventDetector.handleEventHandled(eventID: event.id)
                            }) {
                                Text("Confirm")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                            
                            Button(action: {
                                DataSender.shared.sendUserResponse(event: event, isConfirmed: false)
                                eventDetector.handleEventHandled(eventID: event.id)
                            }) {
                                Text("Dismiss")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Active Events")
        }
    }
}
