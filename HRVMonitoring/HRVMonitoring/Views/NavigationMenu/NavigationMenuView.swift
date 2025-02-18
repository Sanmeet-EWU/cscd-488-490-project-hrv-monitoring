//
//  NavigationMenuView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/14/25.
//

import SwiftUI

struct viewButton: Identifiable {
    var imageName: String
    var buttonText: String
    var navigateTo: AnyView
    var id: String { buttonText }
}

let buttons: [viewButton] = [
    viewButton(
        imageName: "house.fill",
        buttonText: "Home",
        navigateTo: AnyView(NavigationScreenView(destinationView:HomeScreenView(), title: "Home").navigationBarBackButtonHidden(true))
    ),
    viewButton(
        imageName: "chart.bar.xaxis",
        buttonText: "Analytics",
        navigateTo: AnyView(NavigationScreenView(destinationView:AnalyticsScreenView(), title: "Analytics").navigationBarBackButtonHidden(true))
    ),
    viewButton(
        imageName: "exclamationmark.triangle.fill",
        buttonText: "Alerts",
        navigateTo: AnyView(NavigationScreenView(destinationView:AlertsScreenView(), title: "Alerts").navigationBarBackButtonHidden(true))
    ),
    viewButton(
        imageName: "gear.circle.fill",
        buttonText: "Settings",
        navigateTo: AnyView(NavigationScreenView(destinationView:HomeScreenView(), title: "Settings").navigationBarBackButtonHidden(true))
    ),
    viewButton(
        imageName: "phone.fill",
        buttonText: "Contact",
        navigateTo: AnyView(NavigationScreenView(destinationView:HomeScreenView(), title: "Contact").navigationBarBackButtonHidden(true))
    )
]

struct NavigationMenuView: View {
   var body: some View {
       NavigationView {
           Rectangle()
               .fill(LinearGradient(
                   gradient: .init(colors:  [.hrvPrimary, .hrvSecondary]),
                   startPoint: .init(x: 0.1, y: 0.4),
                   endPoint: .init(x: 0.8, y: 0.8)
               ))
               .edgesIgnoringSafeArea(.vertical)
               .overlay {
                   VStack {
                       MenuTitleBar()
                           .padding(.top, 10)
                       ForEach(buttons) { button in
                           NavigationLink(destination: button.navigateTo) {
                               NavigationButtonView(
                                   button_text: button.buttonText,
                                   image: button.imageName
                               )
                                   .padding(.bottom, -10)
                           }
                   }
                   Spacer()
               }
           }
       }
    }
}

#Preview {
    NavigationMenuView()
}
