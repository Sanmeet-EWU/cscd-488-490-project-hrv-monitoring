//
//  NavigationMenuView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/14/25.
//

import SwiftUI

struct NavigationMenuView: View {
    @Binding var currentViewData: NavigationViewData
    @Binding var navigationMenuActive: Bool
    var buttons: [NavigationViewData]
    
   var body: some View {
       HStack {
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
                           NavigationButtonView(
                            currentViewData: $currentViewData,
                            menuActive: $navigationMenuActive,
                            button_text: button.buttonText,
                            image: button.imageName,
                            buttonData: button
                           )
                           .padding(.bottom, -10)
                       }
                       Spacer()
                   }
               }
               .frame(width: 200)
           Spacer()
       }
    }
}

#Preview {
    NavigationMenuView(currentViewData: .constant(NavigationViewData(
        imageName: "phone.fill",
        buttonText: "Contact",
        navigateTo: AnyView(HomeScreenView()))), navigationMenuActive: .constant(false), buttons: [NavigationViewData(
        imageName: "phone.fill",
        buttonText: "Contact",
        navigateTo: AnyView(HomeScreenView())
    )])
}
