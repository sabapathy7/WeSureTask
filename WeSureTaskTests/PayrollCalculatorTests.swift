////
//  PayrollCalculatorTests.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//


import Foundation
import Testing

@testable import WeSureTask

extension Decimal {
    static func exact(_ string: String) -> Decimal {
        guard let value = Decimal(string: string) else {
            preconditionFailure("Not a valid decimal string: \(string)")
        }
        return value
    }
}

@Suite("Payroll Calculator")
struct PayrollCalculatorTests {

    // MARK: - Fixtures

    // Builds an employee for testing
    private func makeEmployee(wages: Decimal, isExempt: Bool = false, name: String = "Test Employee") -> Employee {
        Employee(id: UUID(), name: name, wages: wages, isExempt: isExempt)
    }

    @Test func wagesAtThresholdAreUntaxed() async {
        let employee = makeEmployee(wages: 1000)

        // Act
        let taxes = PayrollCalculator.taxes(for: employee)

        // Assert
        #expect(taxes == 0)
    }

    @Test("Tax threshold boundaries", arguments: [
        (wages: Decimal.exact("999.99"),  expected: Decimal.zero),
        (wages: Decimal.exact("1000"),    expected: Decimal.zero),
        (wages: Decimal.exact("1000.01"), expected: Decimal.exact("50")),
    ])
    func taxThresholdBoundaries(_ wages: Decimal, expected: Decimal) async {
        let employee = makeEmployee(wages: wages)

        /// Act
        let taxes = PayrollCalculator.taxes(for: employee)

        /// Assert
        #expect(taxes == expected)
    }

    @Test("Exemption overrides the threshold at any wage", arguments: [
        Decimal.zero,
        Decimal.exact("9999999.99"),
        Decimal.exact("1000"),
        Decimal.exact("1000.01"),
    ])
    func exemptEmployeesAreNeverTaxed(wages: Decimal) async {
        let employee = makeEmployee(wages: wages, isExempt: true)

        let taxes = PayrollCalculator.taxes(for: employee)

        #expect(taxes == .zero)
    }
}
