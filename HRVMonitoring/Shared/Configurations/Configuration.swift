//
//  Configuration.swift
//  HRVMonitoring
//
//  Created by William Reese on 3/9/25.
//


import Foundation

protocol Configuration {
    var HRV_WINDOW_SIZE: Double {get}
    var MOCK_DATA: Bool {get}
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
    static var active: Configuration {
        switch ProjectConfig.runEnvironment {
            case "Development":
                return DevelopmentConfiguration()
            case "Production":
                return ProductionConfiguration()
            default:
                return ProductionConfiguration()
        }
    }
}
