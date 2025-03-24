//
//  HRVMonitoringWatchApp.swift
//  HRVMonitoringWatch Watch App
//
//  Created by William Reese on 2/17/25.
//

import SwiftUI

@main
struct HRVMonitoringWatch_Watch_AppApp: App {
    // Instantiate the connectivity handler on launch.
    init() {
        _ = WatchConnectivityHandler.shared
    }
    
    @StateObject private var mockHeartRateGenerator = MockHeartRateGenerator.shared
    @StateObject private var dataModeManager = DataModeManager.shared
    @StateObject private var eventDetectionManager = EventDetectionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mockHeartRateGenerator)
                .environmentObject(dataModeManager)
                .environmentObject(eventDetectionManager)
        }
    }
}
