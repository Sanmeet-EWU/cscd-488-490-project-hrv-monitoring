//
//  SwiftUIView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct TopBarView: View {
    @State var isOpen: Bool
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    isOpen = !isOpen
                }
                ) {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(.black)
                }
                    .labelStyle(.iconOnly)
                    .padding(10)
                Spacer()
            }
            HStack {
                Text("Alerts")
                    .font(.title)
                    .bold()
            }
        }
    }
}

#Preview {
    TopBarView(isOpen: false)
}
