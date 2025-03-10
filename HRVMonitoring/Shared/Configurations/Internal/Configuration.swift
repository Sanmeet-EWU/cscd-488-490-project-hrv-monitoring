//
//  Configuration.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/9/25.
//


import Foundation

protocol Configuration {
    // HRV Settings
    /// The size of the HRV calculation window in seconds.
    var HRV_WINDOW_SIZE: Double {get}
    /// If true, use the mock data generator, otherwise if False, use live data.
    var MOCK_DATA: Bool {get}
    /// The RMSSD threshold to trigger events.
    var RMSSD_THRESHOLD: Double {get}
}

enum ConfigurationFile {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

enum ProjectConfig {
    enum Error: Swift.Error {
        case invalidEnvironment
    }
    static var runEnvironment: String {
        return try! ConfigurationFile.value(for: "RUN_ENVIRONMENT")
    }
    static var developmentConfiguration = DevelopmentConfiguration()
    static var productionConfiguration = ProductionConfiguration()
    
    static var active: Configuration {
        switch ProjectConfig.runEnvironment {
            case "Development":
                return ProjectConfig.developmentConfiguration
            case "Production":
                return ProjectConfig.productionConfiguration
            default:
                return ProjectConfig.productionConfiguration
        }
    }
}
