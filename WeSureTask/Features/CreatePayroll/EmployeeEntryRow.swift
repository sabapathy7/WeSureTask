////
//  EmployeeEntryRow.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//


import SwiftUI

struct EmployeeEntryRow: View {
    @Binding var draft: CreatePayrollViewModel.Draft
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Employee Name", text: $draft.name)
                .accessibilityIdentifier("employee.name")
            TextField("Wages", text: $draft.wages)
                .accessibilityIdentifier("employee.wages")
                .keyboardType(.decimalPad)
            Toggle("Exempt from taxes", isOn: $draft.isExempt)
                .accessibilityIdentifier("employee.exempt")
        }
    }
}

#Preview("Empty Row") {
    @Previewable @State var draft = CreatePayrollViewModel.Draft()
    Form {
        EmployeeEntryRow(draft: $draft)
    }
}

#Preview("Filled row") {
    @Previewable @State var draft = CreatePayrollViewModel.Draft(
        name: "Laura Nguyen", wages: "2000"
    )
    Form { EmployeeEntryRow(draft: $draft) }
}
