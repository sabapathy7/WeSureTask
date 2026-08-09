////
//  Employee.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

nonisolated struct Employee: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let wages: Decimal
    let isExempt: Bool
}
