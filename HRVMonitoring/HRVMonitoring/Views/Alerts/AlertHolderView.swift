//
//  AlertHolderView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/15/25.
//

import SwiftUI

struct AlertHolderView: View {
    let events: [Event]

    var body: some View {
        ScrollView {
            ForEach(events) { event in
                AlertView(event: event)
                    .padding(.bottom, 8)
            }
        }
    }
}
