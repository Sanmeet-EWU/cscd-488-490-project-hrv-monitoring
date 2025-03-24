//
//  AnalyticsScreenView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct AnalyticsScreenView: View {
    var body: some View {
        VStack {
            Spacer()
            AnalyticsButtonView()
            Spacer()
            AnalyticsGraphView()
            Spacer()
            AnalyticsStatsView()
            Spacer()
        }
    }
}

#Preview {
    AnalyticsScreenView()
}
