//
//  NavigationButton.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/14/25.
//

import SwiftUI

struct NavigationButtonView: View {
    var button_text: String
    var image: String
    var buttonColor: Color = .clear
    
    var body: some View {
        Rectangle()
            .frame(height: 60)
            .overlay {
                HStack {
                    Image(systemName: image)
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                    Text(button_text)
                        .foregroundColor(.white)
                        .font(.body)
                    Spacer()
                }
                
            }
            .border(width: 2, edges: [.top, .bottom], color: .white)
            .foregroundStyle(buttonColor)
    }
}

#Preview {
    NavigationButtonView(button_text: "Analytics", image: "chart.bar.xaxis")
}
