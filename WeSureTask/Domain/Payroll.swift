////
//  Payroll.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

nonisolated struct Payroll: Identifiable, Hashable, Sendable {
    let id: UUID
    let employees: [Employee]
    let createdAt: Date
    let syncState: SyncState
}

nonisolated enum SyncState: Hashable, Sendable {
    case synced
    case pending
    case failed
}
