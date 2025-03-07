//
//  HomeHeartView.swift
//  HRVMonitoringWatch Watch App
//
//  Created by William Reese on 2/18/25.
//

import SwiftUI


func heartRateEasing(i: Float) -> CGFloat {
    let x: Float = i < 0.5 ? 4.0 * i * i * i : 1.0 - pow(-2.0 * i + 2.0, 3.0) / 2.0;
    return CGFloat(x)
}

struct HomeHeartView: View {
    @ObservedObject var liveHeartRateManager = LiveHeartRateManager.shared
    @ObservedObject var dataModeManager = DataModeManager.shared
    @EnvironmentObject var mockHeartRateGenerator: MockHeartRateGenerator

    @State private var heartStep: Float = 0
    @State private var heartSize: CGFloat = 0.9
    let maxSize: Float = 0.9
    let minSize: Float = 0.7
    let fps: Int = 60

    private var bpm: Float {
        if dataModeManager.isMockMode {
            return Float(mockHeartRateGenerator.currentHeartRate ?? 70)
        } else {
            return Float(liveHeartRateManager.latestHeartRate ?? 70)
        }
    }

    var body: some View {
        HStack {
            VStack {
                Text("\(Int(bpm))")  // Ensure BPM is displayed as an integer
                    .font(.title)
                    .bold()
                Text("BPM")
                    .font(.body)
            }
            .padding(.trailing, 10)

            Image("heart")
                .resizable()
                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
                .foregroundStyle(.red)
                .opacity(0)
                .overlay {
                    GeometryReader { geometry in
                        ZStack {
                            ForEach([1.0, 0.9, 0.8, 0.6], id: \.self) { scale in
                                Image("heart")
                                    .resizable()
                                    .frame(width: geometry.size.width * heartSize * CGFloat(scale),
                                           height: geometry.size.height * heartSize * CGFloat(scale))
                                    .foregroundStyle(.red)
                                    .opacity(scale == 1.0 ? 0.2 : scale == 0.9 ? 0.3 : 0.7)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task {
                            while !Task.isCancelled {
                                try? await Task.sleep(for: .seconds(1.0 / Double(fps)))
                                heartStep += bpm / (60.0 * Float(fps))  // Correct heart rate timing
                                let remainder = heartStep.truncatingRemainder(dividingBy: 1.0)
                                
                                // Keep the easing function behavior the same as iOS
                                heartSize = remainder < 0.5
                                    ? heartRateEasing(i: maxSize - (maxSize - minSize) * remainder * 2)
                                    : heartRateEasing(i: minSize + (maxSize - minSize) * (remainder * 2 - 1.0))
                            }
                        }
                    }
                }
                .zIndex(-1.0)
        }
        .onAppear {
            if dataModeManager.isMockMode {
                mockHeartRateGenerator.startStreamingHeartRate()
                liveHeartRateManager.stopLiveUpdates()
            } else {
                mockHeartRateGenerator.stopStreamingHeartRate()
                liveHeartRateManager.startLiveUpdates()
            }
        }
    }
}


#Preview {
    HomeHeartView()
}
