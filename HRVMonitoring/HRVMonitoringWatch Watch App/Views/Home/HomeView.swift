//
//  HomeScreenView.swift
//  HRVMonitoringWatch Watch App
//
//  Created by William Reese on 2/18/25.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var showEventList = false

    var body: some View {
        VStack {
            HomeHeartView()
            HomeEventButtonView {
                showEventList = true  // Trigger event list display
            }
            .padding(.top, 15)
        }
        .sheet(isPresented: $showEventList) {
            EventListView()
                .environmentObject(EventDetectionManager.shared)
        }
    }
}


#Preview {
    HomeScreenView()
}
