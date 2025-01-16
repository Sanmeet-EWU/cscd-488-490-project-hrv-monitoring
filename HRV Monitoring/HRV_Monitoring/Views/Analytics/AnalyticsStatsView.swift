//
//  AnalyticsStatsView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct AnalyticsStatsView: View {
    var body: some View {
        HStack {
            AnalyticsStatView(statName: "Min")
            Spacer()
            AnalyticsStatView(statName: "Max")
            Spacer()
            AnalyticsStatView(statName: "Avg")
            Spacer()
            AnalyticsStatView(statName: "Alerts")
        }
        .padding([.trailing, .leading], 50)
    }
}

#Preview {
    AnalyticsStatsView()
}
