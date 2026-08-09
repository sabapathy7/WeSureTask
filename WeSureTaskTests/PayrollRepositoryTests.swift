////
//  PayrollRepositoryTests.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 10.08.26.
//

import Foundation
import Testing
@testable import WeSureTask

@Suite("Payroll Repository")
struct PayrollRepositoryTests {
    private let stack = CoreDataStack(inMemory: true)
    private var store: CoreDataPayrollStore { CoreDataPayrollStore(stack: stack) }
    private let laura = Employee(id: UUID(), name: "Laura", wages: .exact("2000"), isExempt: false)

    @Test("Create returns before the push completes")
    func createIsLocalFirst() async throws {
        let repo = PayrollRepositoryImpl(store: store, api: MockPayrollAPI(latency: .zero))
        let payroll = try await repo.createPayroll(employees: [laura])

        #expect(payroll.syncState == .pending)
        #expect(try await store.fetchPayrolls().count == 1)
    }

    @Test("Failed push keeps the record and marks it failed")
    func failedPushKeepsRecord() async throws {
        let api = MockPayrollAPI(latency: .zero, failureMode: .onCreate)
        let repo = PayrollRepositoryImpl(store: store, api: api)

        let payroll = try await repo.createPayroll(employees: [laura])

        #expect(await repo.syncResult(for: payroll.id) == .failed)

        let stored = try #require(await store.fetchPayrolls().first)
        #expect(stored.syncState == .failed)
    }
}
