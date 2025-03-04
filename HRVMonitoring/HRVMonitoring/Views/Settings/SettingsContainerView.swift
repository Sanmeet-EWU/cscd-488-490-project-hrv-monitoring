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
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.clear)
        }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray, lineWidth: 3)
                    .padding()
                    .overlay() {
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
                                    name: "Example",
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
                            .padding(.top, -10)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding([.leading, .trailing], 20)
                        .offset(y: 40)
                    }
            }
    }
}

#Preview {
    SettingsContainerView()
}
