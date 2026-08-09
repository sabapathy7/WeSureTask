////
//  CoreDataPayrollStoreTests.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//


import Testing
@testable import WeSureTask
internal import CoreData

@Suite("Core Data Payroll Store Tests")
struct CoreDataPayrollStoreTests {

    private let stack = CoreDataStack(inMemory: true)
    private var store: CoreDataPayrollStore { CoreDataPayrollStore(stack: stack) }
    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("Inserting a payroll round-trips through the store")
    func insertRoundTrips() async throws {
        let laura = Employee(id: UUID(), name: "Laura", wages: .exact("8.87"), isExempt: false)
        let james = Employee(id: UUID(), name: "James", wages: .exact("1234.56"), isExempt: false)
        let payroll = Payroll(id: UUID(),
                              employees: [laura, james],
                              createdAt: fixedDate,
                              syncState: .pending)

        try await store.insert(payroll)
        let fetched = try #require(await store.fetchPayrolls().first)

        #expect(fetched.id == payroll.id)
        #expect(fetched.createdAt == payroll.createdAt)
        #expect(fetched.syncState == payroll.syncState)

        #expect(fetched.employees == [james, laura])
    }

    @Test("Deleting a payroll cascades to its employees")
    func deleteCascadesToEmployees() async throws {
        let jones = Employee(id: UUID(), name: "Jones", wages: .exact("89929.87"), isExempt: false)
        let saba = Employee(id: UUID(), name: "Saba", wages: .exact("1000.56"), isExempt: false)

        let payroll = Payroll(id: UUID(),
                              employees: [jones, saba],
                              createdAt: fixedDate,
                              syncState: .pending)

        try await store.insert(payroll)

        let context = stack.container.viewContext
        let before = try await context.perform {
            try context.count(for: EmployeeEntity.fetchRequest())
        }
        #expect(before == 2)

        try await store.delete(id: payroll.id)

        let remaining = try await context.perform {
            try context.count(for: EmployeeEntity.fetchRequest())
        }
        #expect(remaining == 0)
    }

    @Test("Testing the update SyncState")
    func testUpdateSyncState() async throws {
        let jones = Employee(id: UUID(), name: "Jones", wages: .exact("89929.87"), isExempt: false)
        let saba = Employee(id: UUID(), name: "Saba", wages: .exact("1000.56"), isExempt: false)

        let payroll = Payroll(id: UUID(),
                              employees: [jones, saba],
                              createdAt: fixedDate,
                              syncState: .pending)
        try await store.insert(payroll)

        let before = try #require(await store.fetchPayrolls().first)
        #expect(before.syncState == .pending)

        try await store.updateSyncState(.failed, for: payroll.id)
        let after = try #require(await store.fetchPayrolls().first)
        #expect(after.syncState == .failed)
        #expect(after.employees.count == 2)
    }

    @Test("Ordering test based on createdDate")
    func testOrderingByCreatedDate() async throws {
        let jones = Employee(id: UUID(), name: "Jones", wages: .exact("89929.87"), isExempt: false)
        let saba = Employee(id: UUID(), name: "Saba", wages: .exact("1000.56"), isExempt: false)

        let older = Payroll(id: UUID(),
                              employees: [jones],
                              createdAt: fixedDate,
                              syncState: .pending)
        let newer = Payroll(id: UUID(),
                            employees: [saba],
                            createdAt: fixedDate.addingTimeInterval(100),
                            syncState: .pending)

        try await store.insert(older)
        try await store.insert(newer)

        let result = try await store.fetchPayrolls()
        #expect(result.map(\.id) == [newer.id, older.id])
    }
}
