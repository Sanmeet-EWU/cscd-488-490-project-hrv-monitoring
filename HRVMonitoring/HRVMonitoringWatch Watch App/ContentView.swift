//
//  ContentView.swift
//  HRVMonitoringWatch Watch App
//
//  Created by William Reese on 2/17/25.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    // HealthKitManager handles authorization and workout session.
    private let healthKitManager = HealthKitManager()
    
    // Live heart rate data.
    @ObservedObject var liveHeartRateManager = LiveHeartRateManager.shared
    
    // The mock generator is used in mock mode.
    @EnvironmentObject var mockHeartRateGenerator: MockHeartRateGenerator
    
    // DataModeManager (a shared singleton) controls the mode.
    @ObservedObject var dataModeManager = DataModeManager.shared
    
    @State private var errorMessage: String?
    @State private var isWorkoutRunning: Bool = false

    // Display heart rate from the appropriate source.
    private var displayedHeartRate: String {
        if dataModeManager.isMockMode {
            return mockHeartRateGenerator.currentHeartRate.map { "\(Int($0)) BPM" } ?? "-"
        } else {
            if let rate = liveHeartRateManager.latestHeartRate {
                return "\(Int(rate)) BPM"
            } else {
                return "Waiting..."
            }
        }
    }
    
    var body: some View {
        VStack {
<<<<<<< HEAD
<<<<<<< HEAD
            
=======
=======
>>>>>>> fed4f02cedc46b8f3de8a6849935903d7fb147ca
            Text("Heart Rate")
                .font(.headline)
                .padding()
            
            Text(displayedHeartRate)
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
            
            Text(isWorkoutRunning ? "🏃‍♂️ Workout Active" : "⏹ Workout Stopped")
                .font(.subheadline)
                .foregroundColor(isWorkoutRunning ? .green : .gray)
            
            // Show events button using the shared EventDetectionManager.
            Button(action: {
                // Toggle display of events.
                mockHeartRateGenerator.showEventList.toggle()
            }) {
                Text("Events (\(EventDetectionManager.shared.events.count))")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $mockHeartRateGenerator.showEventList) {
                EventListView()
                    .environmentObject(EventDetectionManager.shared)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .onAppear {
            print("DataModeManager.isMockMode:", DataModeManager.shared.isMockMode)
            if DataModeManager.shared.isMockMode {
                MockHeartRateGenerator.shared.startStreamingHeartRate()
                LiveHeartRateManager.shared.stopLiveUpdates()
                self.isWorkoutRunning = false
            } else {
                MockHeartRateGenerator.shared.stopStreamingHeartRate()
                LiveHeartRateManager.shared.startLiveUpdates()
                self.isWorkoutRunning = true
            }
<<<<<<< HEAD
>>>>>>> fed4f02cedc46b8f3de8a6849935903d7fb147ca
=======
>>>>>>> fed4f02cedc46b8f3de8a6849935903d7fb147ca
        }
    }
}


#Preview {
    ContentView()
}
