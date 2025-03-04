//
//  SettingView.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/3/25.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .frame(maxHeight: 150)
            .padding([.leading, .trailing], 20)
            .overlay {
                Text("Hello World")
            }
    }
}

#Preview {
    SettingView()
}
