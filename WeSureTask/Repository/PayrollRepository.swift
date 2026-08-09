////
//  PayrollRepository.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

nonisolated protocol PayrollRepository: Sendable {
    func loadPayrolls() async throws -> [Payroll]
    func createPayroll(employees: [Employee]) async throws -> Payroll
    func syncResult(for id: UUID) async -> SyncState
}

actor PayrollRepositoryImpl: PayrollRepository {

    private let store: PayrollStore
    private let api: PayrollAPI
    private var pushes: [UUID: Task<SyncState, Never>] = [:]
    private var hasHydrated = false

    init(store: PayrollStore, api: PayrollAPI) {
        self.store = store
        self.api = api
    }

    func loadPayrolls() async throws -> [Payroll] {
        let local = try await store.fetchPayrolls()

        guard local.isEmpty, !hasHydrated else { return local }
        hasHydrated = true

        guard let remote = try? await api.fetchPayrolls() else { return local }

        for dto in remote {
            try await store.insert(dto.domain)
        }
        return try await store.fetchPayrolls()
    }

    func createPayroll(employees: [Employee]) async throws -> Payroll {
        let payroll = Payroll(id: UUID(), employees: employees, createdAt: .now, syncState: .pending)
        try await store.insert(payroll)

        pushes[payroll.id] = Task {
            await self.push(payroll)
        }
        return payroll
    }

    private func push(_ payroll: Payroll) async -> SyncState {
        let state: SyncState
        do {
            _ = try await api.createPayroll(PayrollDTO(payroll))
            state = .synced
        } catch {
            state = .failed
        }

        try? await store.updateSyncState(state, for: payroll.id)
        return state
    }

    func syncResult(for id: UUID) async -> SyncState {
        guard let task = pushes[id] else {
            return .pending
        }
        let state = await task.value
        pushes[id] = nil
        return state
    }
}
