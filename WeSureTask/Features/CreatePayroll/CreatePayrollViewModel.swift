////
//  CreatePayrollViewModel.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class CreatePayrollViewModel {
    struct Draft: Identifiable {
        let id = UUID()
        var name = ""
        var wages = ""
        var isExempt = false
    }

    var drafts: [Draft] = [Draft()]
    var errorMessage: String?

    private let repository: PayrollRepository

    init(repository: PayrollRepository) {
        self.repository = repository
    }

    private func parseWages(_ text: String) -> Decimal? {
        try? Decimal(text, format: .number.locale(.current))
    }

    var validEmployees: [Employee]? {
        let parsed = drafts.compactMap { draft -> Employee? in
            let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty,
                  let wages = parseWages(draft.wages),
                  wages >= 0 else {
                return nil
            }
            return Employee(id: draft.id, name: name, wages: wages, isExempt: draft.isExempt)
        }
        return parsed.count == drafts.count && !parsed.isEmpty ? parsed : nil
    }

    var canSave: Bool {
        validEmployees != nil
    }

    func addEmployee() {
        drafts.append(Draft())
    }

    func remove(at offsets: IndexSet) {
        drafts.remove(atOffsets: offsets)
    }

    func save() async -> Payroll? {
        guard let employees = validEmployees else {
            return nil
        }

        do {
            return try await repository.createPayroll(employees: employees)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
