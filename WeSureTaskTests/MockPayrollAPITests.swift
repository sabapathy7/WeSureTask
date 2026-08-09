////
//  MockPayrollAPITests.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation
import Testing

@testable import WeSureTask

@Suite("Mock payroll API")
struct MockPayrollAPITests {

    private func makeDTO() -> PayrollDTO {
        PayrollDTO(Payroll(id: UUID(),
                           employees: [Employee(id: UUID(),
                                                name: "New",
                                                wages: .exact("1500"),
                                                isExempt: false)],
                           createdAt: Date(timeIntervalSince1970: 1_700_000_000),
                           syncState: .pending))
    }

    @Test("Seed data - Example payroll")
    func seedMatches() async throws {
        let api = MockPayrollAPI(latency: .zero)

        let payrolls = try await api.fetchPayrolls()
        #expect(payrolls.count == 1)

        let payroll = try #require(payrolls.first).domain
        #expect(payroll.employees.map(\.name) == ["Sarah Mitchell", "James Caldwell", "Laura Nguyen"])
        #expect(payroll.employees.map(\.wages) == [Decimal(900), Decimal(1900), Decimal(2000)])
        #expect(payroll.employees.map(\.isExempt) == [false, true, false])

        #expect(payroll.syncState == .synced)
    }

    @Test("Created payroll appear in next fetch")
    func createIsStateful() async throws {
        let api = MockPayrollAPI(latency: .zero)
        let new = makeDTO()

        let returned = try await api.createPayroll(new)
        #expect(returned == new)

        let payrolls = try await api.fetchPayrolls()
        #expect(payrolls.count == 2)
        #expect(payrolls.contains(new))
    }
}
