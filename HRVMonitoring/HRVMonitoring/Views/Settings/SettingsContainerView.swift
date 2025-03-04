//
//  SettingsMainView.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/3/25.
//

import SwiftUI

struct SettingsContainerView: View {
    var body: some View {
        VStack {
            ScrollView() {
                VStack {
                    Divider()
                        .padding(10)
                    ToggleSettingView(
                        name: "Soothing messages",
                        description: "Placeholder description.",
                        toggled: false
                    )
                    Divider()
                        .padding(10)
                    ToggleSettingView(
                        name: "Example 1",
                        description: "Placeholder description.",
                        toggled: false
                    )
                    Divider()
                        .padding(10)
                    ToggleSettingView(
                        name: "Example 2",
                        description: "Placeholder description.",
                        toggled: false
                    )
                    Divider()
                        .padding(10)
                    ToggleSettingView(
                        name: "Example 3",
                        description: "Placeholder description.",
                        toggled: false
                    )
                    Divider()
                        .padding(10)
                }
            }
            .padding([.leading, .trailing], 20)
        }
    }
}

#Preview {
    SettingsContainerView()
}
