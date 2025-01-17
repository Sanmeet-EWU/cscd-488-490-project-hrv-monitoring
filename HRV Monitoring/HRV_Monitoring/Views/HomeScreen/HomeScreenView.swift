//
//  HomeScreenView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        VStack {
            HomepageHeartView()
                .padding([.top], 100)
            VStack {
                Text("0")
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.secondary) +
                Text("79")
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                Text("BPM")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
                .padding([.top], 20)
            Image("pulse_rate")
                .resizable()
                .aspectRatio(CGSize(width: 1, height: 0.5), contentMode: .fit)
                .foregroundStyle(.red)
                .opacity(0.8)
                .padding(20)
        }
    }
}

#Preview {
    HomeScreenView()
}
