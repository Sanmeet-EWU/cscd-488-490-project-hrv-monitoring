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
                        .foregroundStyle(
                            eventManager.events.count == 0 ? .white : .orange)
                        .bold()
                    +
                    Text(" Events")
                        .font(.caption2)
                        .foregroundStyle(.white)
                }
                .foregroundStyle(.clear)
                .frame(height: 35)
                .padding([.trailing, .leading], 15)
        }
    }
}

#Preview {
    HomeEventButtonView(onTap: {})
}

