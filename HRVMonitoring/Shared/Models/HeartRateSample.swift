//
//  HeartRateSample.swift
//  HRVMonitoringWatch Watch App
//
//  Created by Austin Harrison and Tyler Woody on 2/25/25.
//

import Foundation

struct HeartRateSample: Codable {
    let heartRate: Double
    let timestamp: Date
}
