////
//  PayrollAPI.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import Foundation

nonisolated protocol PayrollAPI: Sendable {
    func fetchPayrolls() async throws -> [PayrollDTO]
    func createPayroll(_ payroll: PayrollDTO) async throws -> PayrollDTO
}
