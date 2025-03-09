//  Editable configuration file for production (release) purposes.
//  Production.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/9/25.
//


struct ProductionConfiguration: Configuration {
    // HRV Settings
    /// The size of the HRV calculation window in seconds.
    var HRV_WINDOW_SIZE: Double = 300.0
    /// If true, use the mock data generator, otherwise if False, use live data.
    var MOCK_DATA: Bool = false
}
