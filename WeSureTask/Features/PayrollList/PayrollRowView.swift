////
//  PayrollRowView.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//


import SwiftUI

struct PayrollRowView: View {
    let payroll: Payroll

    private var summary: PayrollSummary {
        PayrollCalculator.summary(for: payroll)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(payroll.createdAt, format: .dateTime.day().month().year())
                    .font(.headline)
                Text("^[\(payroll.employees.count) employee](inflect: true)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
            }
            
            Spacer()
            Text(summary.totalWages, format: .currency(code: Formatters.currencyCode))
                .monospacedDigit()
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PayrollRowView(payroll: Payroll(id: UUID(), employees: [], createdAt: Date(), syncState: .pending))
}
