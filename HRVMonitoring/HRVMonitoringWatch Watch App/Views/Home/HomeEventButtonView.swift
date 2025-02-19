//
//  HomeEventButtonView.swift
//  HRVMonitoringWatch Watch App
//
//  Created by William Reese on 2/18/25.
//

import SwiftUI

struct HomeEventButtonView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .overlay {
                Text("0")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .bold()
                +
                Text(" Events")
                    .font(.caption2)
                    .foregroundStyle(.white)
            }
            .foregroundStyle(.hrvPrimary)
            .frame(height: 35)
            .padding([.trailing, .leading], 15)
    }
}

#Preview {
    HomeEventButtonView()
}
