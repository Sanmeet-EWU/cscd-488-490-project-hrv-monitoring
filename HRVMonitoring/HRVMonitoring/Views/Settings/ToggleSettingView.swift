//
//  SettingView.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/3/25.
//

import SwiftUI

struct ToggleSettingView: View {
    var name: String
    var description: String
    @State var toggled: Bool
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .frame(height: 60)
            .overlay {
                VStack {
                    Toggle(isOn: $toggled) {
                        VStack {
                            HStack {
                                Text(name)
                                    .font(.headline)
                                Spacer()
                            }
                            HStack {
                                Text(description)
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            .padding([.leading, .trailing], 20)
    }
}

#Preview {
    ToggleSettingView(
        name: "Example",
        description: "Placeholder description",
        toggled: false
    )
}
