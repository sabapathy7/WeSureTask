////
//  WeSureTaskApp.swift
//  WeSureTask
//
//  Created on 07.08.26.
//


import SwiftUI

@main
struct WeSureTaskApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    private let repository: PayrollRepository

    init() {
        let uiTesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
        let stack = CoreDataStack(inMemory: uiTesting)
        let store = CoreDataPayrollStore(stack: stack)
        let api = MockPayrollAPI(
            latency: uiTesting ? .zero : .milliseconds(400),
            seed: uiTesting ? [] : nil
        )
        repository = PayrollRepositoryImpl(store: store, api: api)
    }

    var body: some Scene {
        WindowGroup {
            PayrollListView(viewModel: PayrollListViewModel(repository: repository))
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
