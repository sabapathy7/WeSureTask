////
//  CoreDataStack.swift
//  WeSureTask
//
//  Created by Kanagasabapathy on 09.08.26.
//

import CoreData
import Foundation

nonisolated final class CoreDataStack: @unchecked Sendable {

    nonisolated(unsafe) private static let model: NSManagedObjectModel = {
        guard let url = Bundle(for: CoreDataStack.self).url(forResource: "PayrollModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load Core Data model 'PayrollModel.xcdatamodel'")
        }
        return model
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PayrollModel", managedObjectModel: Self.model)

        if inMemory {
            let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: url)]
        }

        container.loadPersistentStores { description, error in
            if let error {
                fatalError("Failed to load store \(description): \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }
}
