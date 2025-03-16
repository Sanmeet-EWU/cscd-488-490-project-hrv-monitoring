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
            
            TabView {
                Tab("BPM", systemImage: "") {
                    HomeHRVStatView(
                        statistic: "BPM",
                        statisticValue: $connectivityManager.latestHeartRate
                    )
                }
                Tab("RMSSD", systemImage: "") {
                    HomeHRVStatView(
                        statistic: "RMSSD",
                        statisticValue: $connectivityManager.hrvCalculator.latestRMSSD
                    )
                }
                Tab("SDNN", systemImage: "") {
                    HomeHRVStatView(
                        statistic: "SDNN",
                        statisticValue: $connectivityManager.hrvCalculator.latestSDNN
                    )
                }
                Tab("PNN50", systemImage: "") {
                    HomeHRVStatView(
                        statistic: "PNN50",
                        statisticValue: $connectivityManager.hrvCalculator.latestPNN50
                    )
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
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

