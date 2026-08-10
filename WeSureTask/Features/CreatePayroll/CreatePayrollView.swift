////
//  CreatePayrollView.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//


import SwiftUI

struct CreatePayrollView: View {
    @Bindable var viewModel: CreatePayrollViewModel
    @Environment(\.dismiss) private var dismiss
    let onCreated: (Payroll) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Employees") {
                    ForEach($viewModel.drafts) { $draft in
                        EmployeeEntryRow(draft: $draft)
                    }
                    .onDelete(perform: viewModel.remove)

                    Button("Add Employee", systemImage: "plus") {
                        viewModel.addEmployee()
                    }
                    .accessibilityIdentifier("payrolls.new")
                }

                if !viewModel.canSave {
                    Text("Every employee needs a name and a valid wage of 0 or more.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Payroll")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityIdentifier("payroll.create.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if let payroll = await viewModel.save() {
                                onCreated(payroll)
                                dismiss()
                            }
                        }
                    }
                    .accessibilityIdentifier("payroll.create.save")
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

#if DEBUG
#Preview("Empty form — Save disabled") {
    CreatePayrollView(viewModel: CreatePayrollViewModel(repository: StubPayrollRepository()), onCreated: { _ in })
}
#endif

#if DEBUG
#Preview("Valid Form - Save Enabled") {
    let viewModel = CreatePayrollViewModel(repository: StubPayrollRepository())
    viewModel.drafts = [
        .init(name: "Bob", wages: "1000"),
        .init(name: "James", wages: "1900", isExempt: true),
        .init(name: "Laura", wages: "2000")
    ]
    return CreatePayrollView(viewModel: viewModel, onCreated: { _ in })
}
#endif
