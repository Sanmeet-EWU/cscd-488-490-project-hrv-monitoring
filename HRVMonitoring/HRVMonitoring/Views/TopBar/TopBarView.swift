//
//  SwiftUIView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

var backslide: AnyTransition {
    AnyTransition.asymmetric(
        insertion: .move(edge: .leading),
        removal: .move(edge: .trailing))
    .combined(with:
        AnyTransition.offset(x: 200)
    )
}

struct TopBarView: View {
    @Binding var menuActive: Bool
    var title: String
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    withAnimation {
                        menuActive.toggle()
                    }
                }
                ) {
                    Image(systemName: "list.bullet")
                        .foregroundStyle(.black)
                }
                    .labelStyle(.iconOnly)
                    .padding(10)
                Spacer()
            }
                .transition(.move(edge: menuActive ? .leading : .trailing))
            HStack {
                Text(title)
                    .font(.title)
                    .bold()
                    .opacity(menuActive ? 0 : 1)
                    .transition(.opacity)
                    .id("TopBarView" + title)
            }
                
        }
    }
}
