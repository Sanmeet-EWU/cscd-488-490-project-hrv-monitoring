//
//  NavigationScreenView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/22/25.
//

import SwiftUI

struct NavigationScreenView<Content: View>: View {
    @ViewBuilder let destinationView: Content
    var title: String
    @Environment(\.dismiss) private var dismiss
    
    init(destinationView: Content, title: String) {
        self.destinationView = destinationView
        self.title = title
    }
    
    var body: some View {
        VStack {
            TopBarView(title: title, dismiss: dismiss)
                .padding([.top, .trailing, .leading], 20)
            destinationView
        }
    }
}

#Preview {
    NavigationScreenView(destinationView: HomeScreenView(), title: "Home")
}
