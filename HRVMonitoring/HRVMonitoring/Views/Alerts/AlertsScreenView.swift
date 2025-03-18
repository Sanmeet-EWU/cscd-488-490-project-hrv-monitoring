//
//  AlertsScreenView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/15/25.
//

import SwiftUI

struct AlertsScreenView: View {
    @ObservedObject private var eventDetector = EventDetectionManager.shared
    @State var createEvent: Bool = false
    @State var alertsSelected: Bool = true
    @State var warningsSelected: Bool = false
    @State var infoSelected: Bool = false
    
    func createEventFunc() {
        EventDetectionManager.shared.newEvent()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    createEvent = true
                } label: {
                    Image(systemName: "plus")
                }
                .alert(isPresented: $createEvent) {
                    Alert(
                        title: Text("Create Event?"),
                        primaryButton: .default(
                            Text("Create"),
                            action: createEventFunc
                        ),
                        secondaryButton: .destructive(
                            Text("Cancel")
                        )
                    )
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .foregroundColor(.white)
                .background(.hrvSecondaryButton)
                .cornerRadius(16)
                
                AlertsButton(text: "Info", selected: $infoSelected)
                AlertsButton(text: "Warnings", selected: $warningsSelected)
                AlertsButton(text: "Alerts", selected: $alertsSelected)
            }
            .padding(.bottom, 20)
            
            AlertHolderView(
                events: eventDetector.events,
                showAlerts: $alertsSelected
            )
        }
    }
}


#Preview {
    AlertsScreenView()
}
