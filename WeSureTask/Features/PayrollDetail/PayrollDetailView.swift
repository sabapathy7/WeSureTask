////
//  PayrollDetailView.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//


import SwiftUI

struct PayrollDetailView: View {
    let payroll: Payroll

    private var summary: PayrollSummary {
        PayrollCalculator.summary(for: payroll)
    }

    var body: some View {
        List {
            Section("Employees") {
                ForEach(payroll.employees) { employee in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(employee.name).font(.headline)
                        LabeledContent("Total",
                                       value: employee.wages,
                                       format: .currency(code: Formatters.currencyCode))
                        LabeledContent("Taxes",
                                       value: PayrollCalculator.taxes(for: employee),
                                       format: .currency(code: Formatters.currencyCode))
                        LabeledContent("Net",
                                       value: PayrollCalculator.net(for: employee),
                                       format: .currency(code: Formatters.currencyCode))
                    }
                }
                Section("Summary") {
                    PayrollSummaryView(summary: summary)
                }
            }
            .navigationTitle(payroll.createdAt.formatted(date: .abbreviated, time: .omitted))
        }
    }
}

#Preview {
    NavigationStack {
        PayrollDetailView(payroll: .example)
    }
}
