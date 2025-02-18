//
//  HeartView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct HomepageHeartView: View {
    var body: some View {
        Image("heart")
            .resizable()
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
            .foregroundStyle(.red)
            .opacity(0.2)
            .overlay {
                GeometryReader { geometry in
                    ZStack {
                        Image("heart")
                            .resizable()
                            .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.85, alignment: .center)
                            .foregroundStyle(.red)
                            .opacity(0.3)
                        Image("heart")
                            .resizable()
                            .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7, alignment: .center)
                            .foregroundStyle(.red)
                            .opacity(0.3)
                        Image("heart")
                            .resizable()
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5, alignment: .center)
                            .foregroundStyle(.red)
                            .opacity(0.7)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
    }
}

#Preview {
    HomepageHeartView()
}
