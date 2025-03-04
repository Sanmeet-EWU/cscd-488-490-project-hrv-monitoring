//
//  NavigationButton.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/14/25.
//

import SwiftUI

struct NavigationButtonView: View {
    @Binding var currentViewData: NavigationViewData
    @Binding var menuActive: Bool
    var button_text: String
    var image: String
    var buttonColor: Color = .clear
    var buttonData: NavigationViewData
    
    var body: some View {
        Button {
            currentViewData = buttonData
            withAnimation {
                menuActive.toggle()
            }
        }
        label: {
            Image(systemName: image)
                .foregroundColor(.white)
                .padding(.leading, 20)
                .font(.title2)
            Text(button_text)
                .foregroundColor(.white)
                .font(.title2)
            Spacer()
        }
            .frame(height: 80)
            .border(width: 2, edges: [.top, .bottom], color: .white)
            .foregroundStyle(buttonColor)
    }
}

#Preview {
}
