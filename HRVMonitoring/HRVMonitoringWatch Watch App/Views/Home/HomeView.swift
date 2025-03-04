//
//  HomeScreenView.swift
//  HRVMonitoringWatch Watch App
//
//  Created by William Reese on 2/18/25.
//

import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        VStack {
            HomeHeartView()
            HomeEventButtonView()
                .padding(.top, 15)
        }
    }
}

#Preview {
    HomeScreenView()
}
