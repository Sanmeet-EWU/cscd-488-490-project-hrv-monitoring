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
                .padding(.bottom, 50)
            AnalyticsGraphView()
            Spacer()
            AnalyticsStatsView()
                .padding([.bottom], 50)
        }
    }
}

#Preview {
    AnalyticsScreenView()
}
