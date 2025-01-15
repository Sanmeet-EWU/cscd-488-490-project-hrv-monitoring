//
//  NavigationMenuView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/14/25.
//

import SwiftUI

struct NavigationMenuView: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(LinearGradient(
                    gradient: .init(colors:  [.hrvPrimary, .hrvSecondary]),
                    startPoint: .init(x: 0.1, y: 0.4),
                    endPoint: .init(x: 0.8, y: 0.8)
                ))
                .frame(width: 175)
                .edgesIgnoringSafeArea(.vertical)
                .overlay {
                    VStack {
                        MenuTitleBar()
                            .padding(.top, 10)
                        NavigationButtonView(button_text: "Home", image: "house.fill")
                            .padding(.bottom, -10)
                        NavigationButtonView(button_text: "Analytics", image: "chart.bar.xaxis")
                            .padding(.bottom, -10)
                        NavigationButtonView(button_text: "Alerts", image: "exclamationmark.triangle.fill")
                            .padding(.bottom, -10)
                        NavigationButtonView(button_text: "Settings", image: "gear.circle.fill")
                            .padding(.bottom, -10)
                        NavigationButtonView(button_text: "Contact", image: "phone.fill")
                            .padding(.bottom, -10)
                        Spacer()
                    }
                }
            Spacer()
        }
       
    }
}

#Preview {
    NavigationMenuView()
}
