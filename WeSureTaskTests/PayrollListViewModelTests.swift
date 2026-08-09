////
//  Untitled.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 10.08.26.
//

import Foundation
import Testing
@testable import WeSureTask

@MainActor
@Suite("Payroll List View Model")
struct PayrollListViewModelTests {

    @Test("Loading with data produces the loaded state")
    func loadsPayrolls() async {
        let viewModel = PayrollListViewModel(repository:
                                                StubPayrollRepository(payrolls: [.example]))

        await viewModel.load()

        #expect(viewModel.state == .loaded([.example]))
        #expect(viewModel.payrolls.count == 1)
    }

    @Test("Loading with no data produces the empty state")
    func loadsEmpty() async {
        let viewModel = PayrollListViewModel(repository:
                                                StubPayrollRepository(payrolls: []))
        await viewModel.load()

        #expect(viewModel.state == .empty)
        #expect(viewModel.payrolls.isEmpty)
    }

    @Test("A created payroll appears at the top immediately")
    func createdPayrollAppearsFirst() async {
        let viewModel = PayrollListViewModel(
            repository: StubPayrollRepository(payrolls: [.example])
        )
        await viewModel.load()

        let new = Payroll(id: UUID(), employees: [.laura], createdAt: .now, syncState: .pending)
        viewModel.didCreate(new)

        #expect(viewModel.payrolls.first?.id == new.id)
        #expect(viewModel.payrolls.count == 2)
    }
}
