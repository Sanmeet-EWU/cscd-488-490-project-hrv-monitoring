//
//  HomeBPMView.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/16/25.
//

import SwiftUI

struct HomeHRVStatView: View {
    var statistic: String
    @Binding var statisticValue: Double?

    var body: some View {
        // Dynamic heart rate display with custom styling.
        if let heartRate = statisticValue {
            let hrInt = Int(heartRate)
            let hrStr = String(hrInt)
            
            // If the heart rate is less than 100, prepend a "0" with secondary style.
            if hrInt < 100 {
                (Text("0")
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                 +
                 Text(hrStr)
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                )
            } else if (hrInt < 10) {
                (Text("00")
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                 +
                 Text(hrStr)
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                )
            }
            else {
                // For triple digits (and above), style the first digit in secondary and the remainder in primary.
                (Text(String(hrStr.prefix(1)))
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                 +
                 Text(String(hrStr.suffix(from: hrStr.index(hrStr.startIndex, offsetBy: 1))))
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                )
            }
        } else {
            Text("-")
                .bold()
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
        
        Text(statistic)
            .font(.title)
            .foregroundStyle(.secondary)
            .padding(.top, 5)
        
    }
}

#Preview {
    HomeHRVStatView(statistic: "BPM", statisticValue: .constant(nil))
}
