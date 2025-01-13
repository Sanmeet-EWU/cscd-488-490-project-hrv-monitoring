//
//  SwiftUIView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct TopBarView: View {
    var body: some View {
        ZStack {
            HStack {
                Label("Menu", systemImage: "list.bullet")
                    .labelStyle(.iconOnly)
                    .padding(10)
                Spacer()
            }
            HStack {
                Text("Analytics")
                    .font(.title)
                    .bold()
            }
        }
    }
}

#Preview {
    TopBarView()
}
