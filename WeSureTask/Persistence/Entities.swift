////
//  Entities.swift
//  WeSureTask
//
//  Created by kanagasabapathy on 09.08.26.
//

import CoreData
import Foundation

@objc(PayrollEntity)
nonisolated public final class PayrollEntity: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PayrollEntity> {
        NSFetchRequest<PayrollEntity>(entityName: "PayrollEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var syncState: Int16
    @NSManaged public var employees: NSSet?
}

@objc(EmployeeEntity)
nonisolated public final class EmployeeEntity: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmployeeEntity> {
        NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var wages: NSDecimalNumber?
    @NSManaged public var isExempt: Bool
    @NSManaged public var payroll: PayrollEntity?
}
