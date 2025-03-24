//
//  AnalyticsStatView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct AnalyticsStatView: View {
    var statName: String
    var stat: Int = 0
    
    var body: some View {
        VStack {
            Text(statName)
                .font(.title2)
                .foregroundStyle(.primary)
            Text(String(stat))
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AnalyticsStatView(statName: "Min")
}
