//
//  AlertView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/15/25.
//

import SwiftUI

struct AlertView: View {
    let event: Event  // Each AlertView corresponds to a single event
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(.hrvTertiary, lineWidth: 5)
            .background(.white)
            .cornerRadius(20)
            .padding([.leading, .trailing], 20)
            .frame(height: 150)
            .overlay {
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.hrvAlertText)
                            .font(.title3)
                            .padding(.leading, 45)
                        
                        Text("Medical Event Detected")
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundColor(.hrvAlertText)
                        
                        Spacer()
                        
                        // "X" button -> Dismiss
                        Button(action: {
                            // 1) Send 'isConfirmed: false' to phone/watch
                            DataSender.shared.sendUserResponse(event: event, isConfirmed: false)
                            // 2) Remove from active events
                            EventDetectionManager.shared.handleEventHandled(eventID: event.id)
                        }) {
                            Image(systemName: "x.circle")
                                .foregroundColor(.hrvAlertText)
                                .font(.title3)
                                .padding(.trailing, 35)
                        }
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        // You can display any relevant data about this event
                        // e.g., start time or a known BPM at detection.
                        Text("Start: \(event.startTime.formatted())")
                            .padding(.leading, 75)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.hrvAlertText)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        // "Confirm" button -> Confirm
                        Button(action: {
                            // 1) Send 'isConfirmed: true' to phone/watch
                            DataSender.shared.sendUserResponse(event: event, isConfirmed: true)
                            // 2) Remove from active events
                            EventDetectionManager.shared.handleEventHandled(eventID: event.id)
                        }) {
                            Text("Confirm")
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                                .font(.title3)
                                .background(.hrvTertiary)
                                .cornerRadius(16)
                        }
                        .padding(.leading, 75)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
    }
}

#Preview {
    AlertView(
        event: Event(
            id: UUID(),
            startTime: Date.now,
            endTime: Date.now,
            isConfirmed: false
        )
    )
}
