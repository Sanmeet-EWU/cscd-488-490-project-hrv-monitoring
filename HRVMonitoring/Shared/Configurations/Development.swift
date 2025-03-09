//  Editable configuration file for development/testing (debug) purposes.
//  Development.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/9/25.
//

import Foundation

struct DevelopmentConfiguration: Configuration {
    // HRV Settings
    /// The size of the HRV calculation window in seconds.
    var HRV_WINDOW_SIZE: Double = 30.0
    /// If true, use the mock data generator, otherwise if False, use live data.
    var MOCK_DATA: Bool = true
}
