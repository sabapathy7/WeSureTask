////
//  PayrollSummaryTests.swift
//  WeSureTask
//
//  Created on by Kanagasabapathy 09.08.26.
//

import Foundation
import Testing

@testable import WeSureTask

@Suite("Payroll Summary")
struct PayrollSummaryTests {

    private let sarah = Employee(id: UUID(), name: "Sarah Mitchell", wages: .exact("900"), isExempt: false)
    private let james = Employee(id: UUID(), name: "James Cardwell", wages: .exact("1900"), isExempt: true)
    private let laura = Employee(id: UUID(), name: "Laura", wages: .exact("2000"), isExempt: false)

    private var exampleEmployees: [Employee] { [sarah, james, laura] }

    @Test("Per employee salary figures")
    func perEmployeeFigures() async {
        #expect(PayrollCalculator.taxes(for: sarah) == .zero)
        #expect(PayrollCalculator.net(for: sarah) == .exact("900"))

        #expect(PayrollCalculator.taxes(for: james) == .zero)
        #expect(PayrollCalculator.net(for: james) == .exact("1900"))

        #expect(PayrollCalculator.taxes(for: laura) == .exact("100"))
        #expect(PayrollCalculator.net(for: laura) == .exact("1900"))
    }

    @Test("Payroll Summary matches the totals")
    func exampleTotals() async {
        let summary = PayrollCalculator.summary(for: exampleEmployees)

        #expect(summary.totalWages == .exact("4800"))
        #expect(summary.totalTaxes == .exact("100"))
        #expect(summary.totalNetPay == .exact("4700"))
    }

    // MARK: - Hidden Tax Flow

    @Test("Taxes row is shown when any taxes is applied")
    func taxesRowShownWhenTaxed() async {
        let summary = PayrollCalculator.summary(for: exampleEmployees)
        #expect(summary.showsTaxes)
    }

    @Test("Taxes row is hidden when every employee is exempt")
    func taxesRowHiddenWhenAllExempt() async {
        let allExempt = [
                    Employee(id: UUID(), name: "A", wages: .exact("5000"), isExempt: true),
                    Employee(id: UUID(), name: "B", wages: .exact("9999"), isExempt: true),
                ]

        let summary = PayrollCalculator.summary(for: allExempt)

        #expect(summary.totalTaxes == .zero)
        #expect(summary.showsTaxes == false)
    }

    // MARK: - Edges

    @Test("An empty payroll summarises to zero")
    func emptyPayroll() async {

        let summary = PayrollCalculator.summary(for: [])

        #expect(summary == .zero)
    }

    @Test("Summary totals reconcile with the per-employee figures")
    func totalsReconcileWithRows() async {
        let summary = PayrollCalculator.summary(for: exampleEmployees)

        var taxes = Decimal.zero
        var net = Decimal.zero
        for employee in exampleEmployees {
            taxes += PayrollCalculator.taxes(for: employee)
            net   += PayrollCalculator.net(for: employee)
        }

        #expect(summary.totalTaxes == taxes)
        #expect(summary.totalNetPay == net)
    }

    @Test("Summarising a payroll matches summarising its employees")
    func payrollOverloadForwards() async {
        let payroll = Payroll(
            id: UUID(),
            employees: exampleEmployees,
            createdAt: Date(),
            syncState: .pending
        )

        let payrollSummary = PayrollCalculator.summary(for: payroll)
        let employees = PayrollCalculator.summary(for: exampleEmployees)

        #expect(payrollSummary == employees)
    }
}
