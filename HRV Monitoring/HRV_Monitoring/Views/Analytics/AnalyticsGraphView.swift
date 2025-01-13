//
//  AnalyticsGraphView.swift
//  HRV_Monitoring
//
//  Created by William Reese on 1/12/25.
//

import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct AnalyticsGraphView: View {
    var body: some View {
        let yMin = 30
        let yMax = 210
        let xMin = 0
        let xMax = 24
        
        VStack {
            ForEach(0..<7) { i in
                HStack {
                    Text("\(yMin + ((yMax - yMin) / 6) * (6 - i))")
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(height: 1)
                        .opacity(0.3)
                }
                .padding(10)
                
            }
        }
        HStack {
            Spacer()
            ForEach(0..<7) { i in
                Text("\(xMin + ((xMax - xMin) / 6) * i)")
                Spacer()
            }
        }
    }
}

#Preview {
    AnalyticsGraphView()
}
