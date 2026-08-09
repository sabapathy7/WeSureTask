////
//  PayrollDTO.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

nonisolated struct PayrollDTO: Codable, Sendable, Hashable {
    let id: UUID
    let createdAt: Date
    let employees: [EmployeeDTO]
}

nonisolated struct EmployeeDTO: Codable, Sendable, Hashable {
    let id: UUID
    let name: String
    let wages: String
    let isExempt: Bool
}

nonisolated extension PayrollDTO {
    var domain: Payroll {
        Payroll(id: id,
                employees: employees.compactMap(\.domain),
                createdAt: createdAt,
                syncState: .synced)
    }

    init (_ domain: Payroll) {
        self.id = domain.id
        self.createdAt = domain.createdAt
        self.employees = domain.employees.map(EmployeeDTO.init)
    }
}

nonisolated extension EmployeeDTO  {
    var domain: Employee? {
        guard let wages = Decimal(string: wages) else { return nil }
        return Employee(id: id, name: name, wages: wages, isExempt: isExempt)
    }

    init(_ employee: Employee) {
        self.id = employee.id
        self.name = employee.name
        self.wages = employee.wages.description
        self.isExempt = employee.isExempt
    }
}
