//
//  HeartView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

func heartRateEasing(i: Float) -> CGFloat {
    let x: Float = i < 0.5 ? 4.0 * i * i * i : 1.0 - pow(-2.0 * i + 2.0, 3.0) / 2.0;
    return CGFloat(x)
}

struct HomepageHeartView: View {
    @State var bpm: Int = 70
    @State var heartStep: Float = 0
    @State var heartSize: CGFloat = 0.9
    
    let maxSize: Float = 0.9
    let minSize: Float = 0.7
    let fps: Int = 60
    
    var body: some View {
        Image("heart")
            .resizable()
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
            .foregroundStyle(.red)
            .opacity(0)
            .overlay {
                GeometryReader { geometry in
                    ZStack {
                        Image("heart")
                            .resizable()
                            .frame(width: geometry.size.width * heartSize, height: geometry.size.height * heartSize, alignment: .center)
                            .foregroundStyle(.red)
                            .opacity(0.2)
                        Image("heart")
                            .resizable()
                            .frame(width: geometry.size.width * heartSize * 0.9, height: geometry.size.height * heartSize * 0.9, alignment: .center)
                            .foregroundStyle(.red)
                            .opacity(0.3)
                        Image("heart")
                            .resizable()
                            .frame(width: geometry.size.width * heartSize * 0.8, height: geometry.size.height * heartSize * 0.8, alignment: .center)
                            .foregroundStyle(.red)
                            .opacity(0.3)
                        Image("heart")
                            .resizable()
                            .frame(width: geometry.size.width * heartSize * 0.6, height: geometry.size.height * heartSize * 0.6, alignment: .center)
                            .foregroundStyle(.red)
                            .opacity(0.7)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task(id: heartStep) {
                        do {
                            try await Task.sleep(for: .seconds(1.0 / Double(fps)))
                            heartStep += Float(bpm) / (60.0 * Float(fps))
                            var remainder = heartStep.truncatingRemainder(dividingBy: 1.0)
                            if remainder < 0.5 {
                                heartSize = heartRateEasing(i: maxSize - (maxSize - minSize) * remainder * 2)
                            }
                            else {
                                heartSize = heartRateEasing(i: minSize + (maxSize - minSize) * (remainder * 2 - 1.0))
                            }
                        }
                        catch {
                            heartStep = 0
                        }
                    }
                }
            }
            .zIndex(-1.0)
    }
}

#Preview {
    HomepageHeartView()
}
