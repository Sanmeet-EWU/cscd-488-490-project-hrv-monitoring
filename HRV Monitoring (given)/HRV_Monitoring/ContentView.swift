//
//  ContentView.swift
//  HRV Monitoring
//
//  Created by William Reese on 12/2/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
//            NavigationMenuView()
//                .zIndex(1)
            VStack {
                TopBarView(isOpen: false)
                    .padding([.top, .trailing, .leading], 20)
                HomeScreenView()
            }
        }
    }
}

#Preview {
    ContentView()
}
