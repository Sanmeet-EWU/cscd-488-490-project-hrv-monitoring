//
//  AnalyticsButtonView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct AnalyticsButtonView: View {
    var body: some View {
        HStack {
            Button {} label: {
                Text("Day")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .font(.title3)
                    .background(.hrvButtonSelected)
                    .cornerRadius(16)
            }
            Button {} label: {
                Text("Month")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .font(.title3)
                    .background(.hrvPrimary)
                    .cornerRadius(16)
            }
            Button {} label: {
                Text("Year")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .font(.title3)
                    .background(.hrvPrimary)
                    .cornerRadius(16)
            }
        }
        
    }
}

#Preview {
    AnalyticsButtonView()
}
