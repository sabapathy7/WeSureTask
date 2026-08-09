////
//  PayrollCalculator.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

nonisolated struct PayrollSummary: Hashable, Sendable {
    let totalWages: Decimal
    let totalTaxes: Decimal
    let totalNetPay: Decimal
    var showsTaxes: Bool { totalTaxes > 0 }
    static let zero = PayrollSummary(totalWages: 0, totalTaxes: 0, totalNetPay: 0)
}

nonisolated enum PayrollCalculator {
    static let taxThreshold: Decimal = 1000

    static let taxRate = Decimal(sign: .plus, exponent: -2, significand: 5)

    static let currencyScale = 2
    static let roundingMode: NSDecimalNumber.RoundingMode = .plain

    static func taxes(for employee: Employee) -> Decimal {
        guard !employee.isExempt, employee.wages > taxThreshold else { return 0 }
        return rounded(employee.wages * taxRate)

    }

    static func net(for employee: Employee) -> Decimal {
        employee.wages - taxes(for: employee)
    }

    static func summary(for payroll: Payroll) -> PayrollSummary {
        summary(for: payroll.employees)
    }

    static func summary(for employees: [Employee]) -> PayrollSummary {
        let totals = employees.reduce(into: (wages: Decimal.zero, taxes: Decimal.zero)) {running,employee in
            running.wages += employee.wages
            running.taxes += taxes(for: employee)
        }
        return PayrollSummary(totalWages: totals.wages, totalTaxes: totals.taxes, totalNetPay: totals.wages - totals.taxes)
    }

    private static func rounded(_ value: Decimal) -> Decimal {
        var input = value
        var result = Decimal.zero
        NSDecimalRound(&result, &input, currencyScale, roundingMode)
        return result
    }
}
