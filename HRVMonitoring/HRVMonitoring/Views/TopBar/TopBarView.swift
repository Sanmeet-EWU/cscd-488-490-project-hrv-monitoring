//
//  SwiftUIView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct TopBarView: View {
    var title: String
    var dismiss: DismissAction
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    dismiss()
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
                Text(title)
                    .font(.title)
                    .bold()
            }
        }
    }
}
