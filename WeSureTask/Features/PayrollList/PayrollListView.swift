////
//  PayrollListView.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//


import SwiftUI

struct PayrollListView: View {

    @State var viewModel: PayrollListViewModel
    @State private var isCreating: Bool = false
    init(viewModel: PayrollListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Payrolls")
                .accessibilityIdentifier("payrolls.list")
                .navigationDestination(for: Payroll.self) {
                    PayrollDetailView(payroll: $0)
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("New Payroll", systemImage: "plus") {
                            isCreating = true
                        }
                    }
                }
                .sheet(isPresented: $isCreating) {
                    CreatePayrollView(viewModel: viewModel.makeCreateViewModel(),
                                      onCreated: {payroll in
                        viewModel.didCreate(payroll)
                        Task {
                            await viewModel.observeSync(of: payroll)
                        }
                    })
                }
                .task {
                    await viewModel.load()
                }
                .safeAreaInset(edge: .bottom) {
                    if let banner = viewModel.banner {
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(banner)
                                .font(.subheadline)
                            Spacer(minLength: 0)
                            Button("Dismiss") {
                                viewModel.banner = nil
                            }
                            .font(.subheadline.weight(.semibold))
                        }
                        .padding(12)
                        .background(.thinMaterial, in: .rect(cornerRadius: 12))
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.default, value: viewModel.banner)
        }
    }
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .empty:
            ContentUnavailableView("No payrolls yet", systemImage: "doc.text", description: Text("Tap + to create your first payroll"))
        case .failed(let error):
            ContentUnavailableView("Couldn't load payrolls", systemImage: "exclamationmark.triangle", description: Text(error))
        case .loaded(let payrolls):
            List(payrolls) { payroll in
                NavigationLink(value: payroll) {
                    PayrollRowView(payroll: payroll)
                }
            }
        }
    }
}


#Preview {
    PayrollListView(viewModel: PayrollListViewModel(repository: StubPayrollRepository(payrolls: [.example])))
}
