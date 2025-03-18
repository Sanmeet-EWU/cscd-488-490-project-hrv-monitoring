//
//  AlertHolderView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/15/25.
//

import SwiftUI

struct AlertHolderView: View {
    let events: [Event]
    @Binding var showAlerts: Bool

    var body: some View {
        ScrollView {
            VStack {
                if showAlerts {
                    ForEach(Array(events)) { event in
                        ZStack {
                            AlertView(event: event)
                                .padding(.bottom, 8)
                                
                        }
                        .zIndex(1)
                        .transition(.opacity)
                        
                    }
                }
            }
        }
    }
}

#Preview {
    AlertHolderView(
        events: [
            Event(
                id: UUID(),
                startTime: Date.now,
                endTime: Date.now,
                isConfirmed: false
            )
        ],
        showAlerts: .constant(true)
    )
}

