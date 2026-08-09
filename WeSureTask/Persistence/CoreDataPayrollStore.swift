////
//  CoreDataPayrollStore.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import CoreData
import Foundation

nonisolated protocol PayrollStore: Sendable {
    func fetchPayrolls() async throws -> [Payroll]
    func insert(_ payroll: Payroll) async throws
    func updateSyncState(_ state: SyncState, for id: UUID) async throws
    func delete(id: UUID) async throws
}

nonisolated final class CoreDataPayrollStore: PayrollStore, @unchecked Sendable {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func fetchPayrolls() async throws -> [Payroll] {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = PayrollEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \PayrollEntity.createdAt, ascending: false)]
            return try context.fetch(request).compactMap(self.makePayroll)
        }
    }

    private func makePayroll(_ entity: PayrollEntity) -> Payroll? {
        guard let id = entity.id,
              let createdAt = entity.createdAt else
        {
            return nil
        }
        let rows = entity.employees as? Set<EmployeeEntity> ?? []

        return Payroll(id: id,
                       employees: rows.compactMap(makeEmployee).sorted {$0.name < $1.name },
                       createdAt: createdAt,
                       syncState: SyncState(storeValue: entity.syncState))
    }

    private func makeEmployee(_ entity: EmployeeEntity) -> Employee? {
        guard let id = entity.id,
              let name = entity.name,
              let wages = entity.wages else {
            return nil
        }
        return Employee(id: id,
                        name: name,
                        wages: wages.decimalValue,
                        isExempt: entity.isExempt)
    }

    func insert(_ payroll: Payroll) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            let entity = PayrollEntity(context: context)
            entity.id = payroll.id
            entity.createdAt = payroll.createdAt
            entity.syncState = payroll.syncState.storedValue

            for employee in payroll.employees {
                let row = EmployeeEntity(context: context)
                row.id = employee.id
                row.name = employee.name
                row.wages = NSDecimalNumber(value: (employee.wages as NSDecimalNumber).doubleValue)
                row.isExempt = employee.isExempt
                row.payroll = entity

            }
            try context.save()
        }
    }
    
    func updateSyncState(_ state: SyncState, for id: UUID) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            let request = PayrollEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else {
                return
            }
            entity.syncState = state.storedValue
            try context.save()
        }
    }
    
    func delete(id: UUID) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            let request = PayrollEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else {
                return
            }
            context.delete(entity)
            try context.save()
        }
    }
}

// MARK: - SyncState persistence encoding — a store-layer concern only

nonisolated private extension SyncState {
    var storedValue: Int16 {
        switch self {
        case .synced: 0
        case .pending: 1
        case .failed: 2
        }
    }

    init(storeValue: Int16) {
        switch storeValue {
        case 0: self = .synced
        case 2: self = .failed
        default: self = .pending
        }
    }
}
