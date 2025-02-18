//
//  AlertsButton.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/15/25.
//

import SwiftUI

struct AlertsButton: View {
    var text: String
    var selected: Bool
    
    var body: some View {
        Button {} label: {
            Image(systemName: selected ? "checkmark" : "xmark")
            Text(text)
                .font(.title3)
        }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .foregroundColor(.white)
            .background(selected ? .hrvSecondary : .hrvSecondaryButton)
            .cornerRadius(16)
    }
}

#Preview {
    AlertsButton(text: "Warnings", selected: true)
}
