//
//  SettingsMainView.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/3/25.
//

import SwiftUI

struct SettingsContainerView: View {
    @State var showPersonalInfoSheet = false

    var body: some View {
        VStack {
            ScrollView() {
                VStack {
                    PersonalInfoSettingView(
                        name: "Personal Information",
                        description: "Change personal information.",
                        show: $showPersonalInfoSheet
                    )
                    Divider()
                        .padding(10)
                    ToggleSettingView(
                        name: "Soothing messages",
                        description: "Toggle soothing messages.",
                        toggled: false
                    )
                    Divider()
                        .padding(10)
                }
            }
            .padding([.leading, .trailing], 20)
        }
        .sheet(
            isPresented: $showPersonalInfoSheet,
            content: {
                OnboardingView(onCompleted: {
                    showPersonalInfoSheet = !showPersonalInfoSheet
                })
            }
        )
    }
}

#Preview {
    SettingsContainerView()
}
