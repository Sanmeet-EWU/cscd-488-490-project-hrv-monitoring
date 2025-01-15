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
                    .font(.title3)
                +
                Text("HRV")
                    .foregroundStyle(.white)
                    .bold()
                    .font(.title3)
                Spacer()
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.white)
                    .bold()
                    .padding(.trailing, 10)
            }
    }
}

#Preview {
    MenuTitleBar()
}
