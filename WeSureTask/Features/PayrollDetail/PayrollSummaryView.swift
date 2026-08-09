////
//  PayrollSummaryView.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//


import SwiftUI

struct PayrollSummaryView: View {
    let summary: PayrollSummary

    var body: some View {
        LabeledContent("Total",
                       value: summary.totalWages,
                       format: .currency(code: Formatters.currencyCode))

        if summary.showsTaxes {
            LabeledContent("Total Taxes",
                           value: summary.totalTaxes,
                           format: .currency(code: Formatters.currencyCode))
        }

        LabeledContent("Total Net",
                       value: summary.totalNetPay,
                       format: .currency(code: Formatters.currencyCode))
            .fontWeight(.semibold)
    }
}

#Preview {
    Form {
        PayrollSummaryView(summary: PayrollCalculator.summary(for: .example))
    }
}

#Preview("All exempt — no taxes row") {
    Form {
        PayrollSummaryView(summary: PayrollCalculator.summary(for: .allExempt))
    }
}
