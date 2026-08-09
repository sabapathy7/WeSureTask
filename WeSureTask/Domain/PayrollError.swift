////
//  PayrollError.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

nonisolated enum PayrollError: Error, Equatable, LocalizedError {
    case network
    case invalidSeedData

    var errorDescription: String? {
        switch self {
        case .network:
            String(localized: "Couldn't reach the server.")
        case .invalidSeedData:
            String(localized: "Couldn't read the data")
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .network:
            String(localized: "Payrolls are saved on this device")
        case .invalidSeedData:
            nil
        }
    }
}
