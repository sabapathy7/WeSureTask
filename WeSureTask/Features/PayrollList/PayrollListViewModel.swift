////
//  PayrollListViewModel.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class PayrollListViewModel {
    enum State: Equatable {
        case loading, loaded([Payroll]), empty, failed(String)
    }

    private(set) var state: State = .loading
    private let repository: PayrollRepository
    var banner: String?
    var payrolls: [Payroll] {
        if case .loaded(let payrolls) = state {
            return payrolls
        }
        return []
    }
    init(repository: PayrollRepository) {
        self.repository = repository
    }

    func makeCreateViewModel() -> CreatePayrollViewModel {
        CreatePayrollViewModel(repository: repository)
    }

    func didCreate(_ payroll: Payroll) {
        state = .loaded([payroll] + payrolls)
    }

    func observeSync(of payroll: Payroll) async {
        Task {
            if await repository.syncResult(for: payroll.id) == .failed {
                banner = "Saved on this device. Couldn't reach the server"
            }
            await load()
        }
    }

    func load() async {
        if payrolls.isEmpty {
            state = .loading
        }

        do {
            let payrolls = try await repository.loadPayrolls()
            state = payrolls.isEmpty ? .empty : .loaded(payrolls)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
