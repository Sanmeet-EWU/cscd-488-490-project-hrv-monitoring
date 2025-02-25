//
//  HomeScreenView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI
import HealthKit

struct HomeScreenView: View {
    @StateObject private var connectivityManager = PhoneConnectivityManager.shared
    
    var body: some View {
        VStack {
            HomepageHeartView()
                .padding(.top, 100)
            
            // Dynamic heart rate display with custom styling.
            if let heartRate = connectivityManager.latestHeartRate {
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
                } else {
                    // For triple digits (and above), style the first digit in secondary and the remainder in primary.
                    (Text(String(hrStr.prefix(1)))
                        .bold()
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                     +
                     Text(String(hrStr.suffix(from: hrStr.index(hrStr.startIndex, offsetBy: 1))))
                        .bold()
                        .font(.largeTitle)
                        .foregroundStyle(.primary)
                    )
                }
            } else {
                Text("-")
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            
            Text("BPM")
                .font(.title)
                .foregroundStyle(.secondary)
                .padding(.top, 5)
            
            Image("pulse_rate")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300)
                .foregroundStyle(.red)
                .opacity(0.8)
                .padding(20)
            
            Spacer()
        }
        .onAppear {
            print("HomeScreenView appeared. Latest HR:", connectivityManager.latestHeartRate as Any)
        }
    }
}

#Preview {
    HomeScreenView()
}

