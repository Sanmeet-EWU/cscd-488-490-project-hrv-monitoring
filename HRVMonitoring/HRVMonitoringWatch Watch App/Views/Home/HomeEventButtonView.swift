//
//  HomeEventButtonView.swift
//  HRVMonitoringWatch Watch App
//
//  Created by William Reese on 2/18/25.
//

import SwiftUI

struct HomeEventButtonView: View {
    @ObservedObject var eventManager = EventDetectionManager.shared
    var onTap: () -> Void  // Closure to handle tap action

    var body: some View {
        Button(action: {
            onTap()  // Call the provided action when tapped
        }) {
            RoundedRectangle(cornerRadius: 10)
                .overlay {
                    Text("\(eventManager.events.count)")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .bold()
                    +
                    Text(" Events")
                        .font(.caption2)
                        .foregroundStyle(.white)
                }
                .foregroundStyle(.hrvPrimary)
                .frame(height: 35)
                .padding([.trailing, .leading], 15)
        }
    }
}
