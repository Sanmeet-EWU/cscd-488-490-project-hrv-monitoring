//
//  PersistenceController.swift
//  HRVMonitoring
//
//  Created by Tyler Woody and Austin Harrison on 2/18/25.
//

import Foundation
import Combine

class DataModeManager: ObservableObject {
    static let shared = DataModeManager()
    
    // Set the default mode here (false = live, true = mock)
    @Published var isMockMode: Bool = true
}
