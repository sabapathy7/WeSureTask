////
//  PreviewData.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

#if DEBUG
nonisolated extension Employee {
    static let sarah = Employee(id: UUID(), name: "Sarah Mitchell", wages: Decimal(900),  isExempt: false)
    static let james = Employee(id: UUID(), name: "James Caldwell", wages: Decimal(1900), isExempt: true)
    static let laura = Employee(id: UUID(), name: "Laura Nguyen",   wages: Decimal(2000), isExempt: false)
}
nonisolated extension Payroll {
    static let example = Payroll(id: UUID(),
                                 employees: [.sarah, .james, .laura],
                                 createdAt: .now,
                                 syncState: .synced)
    static let allExempt = Payroll(id: UUID(),
                                   employees: [.james],
                                   createdAt: .now,
                                   syncState: .pending)
}
struct StubPayrollRepository: PayrollRepository {
    var payrolls: [Payroll] = [.example]
    var loadError: Error?
    var syncState: SyncState = .synced

    func loadPayrolls() async throws -> [Payroll] {
        if let loadError { throw loadError }
        return payrolls
    }
    func createPayroll(employees: [Employee]) async throws -> Payroll {
        Payroll(id: UUID(),
                employees: employees,
                createdAt: Date(),
                syncState: .pending)
    }
    func syncResult(for id: UUID) async -> SyncState {
        syncState
    }
}
#endif
