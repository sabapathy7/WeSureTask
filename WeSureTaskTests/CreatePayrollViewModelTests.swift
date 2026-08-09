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
@Suite("Create payroll View Model")
struct CreatePayrollViewModelTests {

    private func makeViewModel() -> CreatePayrollViewModel {
        CreatePayrollViewModel(repository: StubPayrollRepository())
    }

    // MARK: - Validation

    @Test("A fresh form cannot be saved")
    func freshFormIsInvalid() {
        #expect(makeViewModel().canSave == false)
    }


    @Test("Whitespace rejected")
    func whitespaceNameIsInvalid() {
        let viewModel = makeViewModel()
        viewModel.drafts = [.init(name: "   ", wages: "2000")]

        #expect(viewModel.canSave == false)
    }

    @Test("negative wages are rejected")
    func negativeWagesAreInvalid() {
        let viewModel = makeViewModel()
        viewModel.drafts = [.init(name: "Laura", wages: "-2000")]

        #expect(viewModel.canSave == false)
    }

    @Test("Complete valid is valid and trims names")
    func completeFormIsValid() throws {
        let viewModel = makeViewModel()
        viewModel.drafts = [.init(name: " Laura Nguyen  ", wages: "2000")]

        let employees = try #require(viewModel.validEmployees)
        #expect(employees.count == 1)
        #expect(employees[0].name == "Laura Nguyen")
        #expect(employees[0].wages == .exact("2000"))
        #expect(viewModel.canSave)

    }

    // MARK: - Locale

    @Test("Wages parse with the device's decimal separator")
    func wagesRespectLocaleSeparator() throws {
        let separator = Locale.current.decimalSeparator ?? "."
        let viewModel = makeViewModel()
        viewModel.drafts = [.init(name: "Laura", wages: "1234\(separator)56")]

        let employees = try #require(viewModel.validEmployees)
        #expect(employees[0].wages == .exact("1234.56"))   // not 1234
    }
}
