//
//  AlertsScreenView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/15/25.
//

import SwiftUI

struct AlertsScreenView: View {
    @ObservedObject private var eventDetector = EventDetectionManager.shared
    
    var body: some View {
        VStack {
            HStack {
                Button {} label: {
                    Image(systemName: "plus")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .foregroundColor(.white)
                .background(.hrvSecondaryButton)
                .cornerRadius(16)
                
                AlertsButton(text: "Info", selected: false)
                AlertsButton(text: "Warnings", selected: true)
                AlertsButton(text: "Alerts", selected: true)
            }
            .padding(.bottom, 20)
            
            AlertHolderView(events: eventDetector.events)
        }
    }
}


#Preview {
    AlertsScreenView()
}
