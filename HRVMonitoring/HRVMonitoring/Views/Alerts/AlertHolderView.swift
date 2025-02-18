//
//  AlertHolderView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/15/25.
//

import SwiftUI

struct AlertHolderView: View {
    var body: some View {
        ScrollView {
            AlertView()
            AlertView()
            AlertView()
            AlertView()
            AlertView()
            AlertView()
        }
    }
}

#Preview {
    AlertHolderView()
}
