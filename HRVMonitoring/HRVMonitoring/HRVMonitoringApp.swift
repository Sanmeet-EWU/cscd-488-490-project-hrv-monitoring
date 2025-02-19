//
//  HRVMonitoringApp.swift
//  HRVMonitoring
//
//  Created by William Reese on 2/17/25.
//

import SwiftUI

@main
struct HRVMonitoringApp: App {
    @StateObject private var connectivityManager = PhoneConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityManager)
        }
    }
}
