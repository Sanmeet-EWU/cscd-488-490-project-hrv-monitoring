//
//  ContentView.swift
//  HRV Monitoring
//
//  Created by William Reese on 12/2/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TopBarView()
                .padding(20)
            Spacer()
            HomeScreenView()
        }
    }
}

#Preview {
    ContentView()
}
