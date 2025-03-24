//
//  MenuTitleBar.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/14/25.
//

import SwiftUI

struct MenuTitleBar: View {
    var body: some View {
            HStack {
                Spacer()
                Text("St. Lukes ")
                    .foregroundStyle(.white)
                    .font(.title)
                +
                Text("HRV")
                    .foregroundStyle(.white)
                    .bold()
                    .font(.title)
                Spacer()
            }
    }
}

#Preview {
    MenuTitleBar()
}
