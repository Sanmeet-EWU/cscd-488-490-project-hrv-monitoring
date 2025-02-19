//
//  PulseRateView.swift
//  HRVMonitoring
//
//  Created by William Reese on 2/19/25.
//

import SwiftUI

<<<<<<< HEAD
struct BeatStruct {
=======
struct Beat {
>>>>>>> 214889f61b37531d2195fb908101812a56a71858
    var delta: Double
}

struct PulseRateView: View {
    @State var pulseStep: Double = 0
    @State var bpmStep: Double = 0
<<<<<<< HEAD
    @State var beats: [BeatStruct] = []
=======
    @State var beats: [Beat] = []
>>>>>>> 214889f61b37531d2195fb908101812a56a71858
    let beatYRadius: Double = 0.5
    let beatXRadius: Double = 0.05
    let baseHeight: Double = 0.5
    let bpm: Int = 83
    let fps: Int = 60
    let cycleTimeSeconds: Double = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                var points: [CGPoint] = [CGPoint(x: -beatXRadius * 2, y: baseHeight)]
                // Calculate points
                let interpolationDelta: Double = 1 + beatXRadius * 2
                for i in 0..<self.beats.count {
                    let beat = self.beats[i]
                    let delta: Double = pulseStep - beat.delta
                    if delta > 1 {
                        self.beats.remove(at: i)
                    }
                    else {
                        // Rightmost point
                        // Upwards points
                        // Downwards point
                        // Leftmost point
                        points.append(CGPoint(x: 1 - (interpolationDelta * delta), y: 0.5))
                    }
                }
                points.append(CGPoint(x: 1 + beatXRadius * 2, y: baseHeight))
                for i in 1..<points.count {
                    path.move(to: CGPoint(x: geometry.size.width * points[i-1].x, y: geometry.size.height * points[i-1].y))
                    path.addLine(to: CGPoint(x: geometry.size.width * points[i].x, y: geometry.size.height * points[i].y))
                }
            }
            .stroke(Color.red, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .clipShape(Rectangle())
        .padding([.leading, .trailing], 50)
        .task(id: pulseStep) {
            do {
                try await Task.sleep(for: .seconds(1.0 / Double(fps)))
                let step: Double = (1.0 / Double(fps)) / cycleTimeSeconds
                let beatStep: Double = (1.0 / Double(bpm)) * cycleTimeSeconds
                pulseStep += step
                if pulseStep > bpmStep + beatStep {
<<<<<<< HEAD
                    beats.append(BeatStruct(delta: bpmStep))
=======
                    beats.append(Beat(delta: bpmStep))
>>>>>>> 214889f61b37531d2195fb908101812a56a71858
                    bpmStep = pulseStep
                }
            }
            catch {
                pulseStep = 0
            }
        }
    }
}

#Preview {
    PulseRateView()
}
