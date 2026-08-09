////
//  MockPayrollAPI.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

private final class BundleMarker {}

actor MockPayrollAPI: PayrollAPI {

    enum FailureMode: Sendable {
        case never, always, onFetch, onCreate
    }
    private var stored: [PayrollDTO]?
    private let latency: Duration
    private let seed: [PayrollDTO]?
    private let failureMode: FailureMode

    init(latency: Duration = .milliseconds(400),
         failureMode: FailureMode = .never,
         seed: [PayrollDTO]? = nil) {
        self.latency = latency
        self.failureMode = failureMode
        self.seed = seed
    }

    private enum APIOperation: Sendable {
        case fetch
        case create
    }

    func fetchPayrolls() async throws -> [PayrollDTO] {
        try await simulate(.fetch)
        return try hydrated()
    }


    func createPayroll(_ payroll: PayrollDTO) async throws -> PayrollDTO {
        try await simulate(.create)
        var current = try hydrated()
        current.append(payroll)
        stored = current
        return payroll
    }

    private func hydrated() throws -> [PayrollDTO] {
        if let stored {
            return stored
        }
        if let seed {
            stored = seed
            return seed
        }
        let loaded = try Self.loadSeed()
        stored = loaded
        return loaded
    }

    private static func loadSeed() throws -> [PayrollDTO] {
        guard let url = Bundle(for: BundleMarker.self).url(forResource: "payrolls", withExtension: "json"),
              let data = try? Data(contentsOf: url)
                else { throw PayrollError.network }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode([PayrollDTO].self, from: data)
        } catch {
            throw PayrollError.invalidSeedData
        }
    }

    private func simulate(_ operation: APIOperation) async throws {
        try await Task.sleep(for: latency)
        switch failureMode {
        case .never:
            break
        case .always:
            throw PayrollError.network
        case .onFetch:
            if operation == .fetch {
                throw PayrollError.network
            }
        case .onCreate:
            if operation == .create {
                throw PayrollError.network
            }
        }
    }
}
