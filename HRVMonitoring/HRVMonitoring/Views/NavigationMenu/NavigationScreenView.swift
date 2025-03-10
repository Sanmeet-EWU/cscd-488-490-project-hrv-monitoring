//
//  NavigationScreenView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/22/25.
//

import SwiftUI

struct NavigationViewData: Identifiable {
    var imageName: String
    var buttonText: String
    var navigateTo: any View
    var id: String { buttonText }
}

let navigationViewData: [NavigationViewData] = [
    NavigationViewData(
        imageName: "house.fill",
        buttonText: "Home",
        navigateTo: HomeScreenView()
    ),
    NavigationViewData(
        imageName: "chart.bar.xaxis",
        buttonText: "Analytics",
        navigateTo: AnalyticsScreenView()
    ),
    NavigationViewData(
        imageName: "exclamationmark.triangle.fill",
        buttonText: "Alerts",
        navigateTo: AlertsScreenView()
    ),
    NavigationViewData(
        imageName: "gear.circle.fill",
        buttonText: "Settings",
        navigateTo: SettingsContainerView()
    ),
    NavigationViewData(
        imageName: "phone.fill",
        buttonText: "Contact",
        navigateTo: HomeScreenView()
    )
]

struct NavigationScreenView: View {
    @State private var navigationMenuActive: Bool = false
    @State var currentView = NavigationViewData(
        imageName: "house.fill",
        buttonText: "Home",
        navigateTo: AnyView(HomeScreenView())
    )
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                HStack {
                    TopBarView(menuActive: $navigationMenuActive, title: currentView.buttonText)
                        .padding([.top, .leading, .trailing], 20)
                }
                .padding(.leading, navigationMenuActive ? 200 : 0)
                
                AnyView(currentView.navigateTo)
            }
            .contentShape(Rectangle())
            .blur(radius: navigationMenuActive ? 10 : 0)
            .animation(.easeInOut, value: navigationMenuActive)
            .onTapGesture {
                if navigationMenuActive {
                    withAnimation(.easeInOut) {
                        navigationMenuActive = false
                    }
                }
            }
            
            if navigationMenuActive {
                NavigationMenuView(
                    currentViewData: $currentView,
                    navigationMenuActive: $navigationMenuActive,
                    buttons: navigationViewData
                )
                .frame(width: 200)
                .transition(.move(edge: .leading))
                .zIndex(1)
            }
        }
    }
}

#Preview {
    NavigationScreenView()
}
