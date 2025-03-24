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
            Spacer()
            AnalyticsStatView(statName: "Min")
            AnalyticsStatView(statName: "Max")
                .padding(.leading, 20)
                .padding(.trailing, 10)
            AnalyticsStatView(statName: "Avg")
                .padding(.trailing, 20)
                .padding(.leading, 10)
            AnalyticsStatView(statName: "Alerts")
            Spacer()
        }
        .padding([.trailing, .leading], 50)
    }
}

#Preview {
    AnalyticsStatsView()
}
