//
//  Event.swift
//  HRVMonitoring
//
//  Created by Tyler Woody on 2/18/25.
//

import Foundation

struct Event: Identifiable, Codable {
    let id: UUID // Unique identifier for the event
    let startTime: Date
    var endTime: Date
    var isConfirmed: Bool?
}
