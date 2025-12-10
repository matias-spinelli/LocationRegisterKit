//
//  DataController.swift
//  iSucurgal
//
//  Created by Matías Spinelli on 05/12/2025.
//

import CoreData
import Foundation

@MainActor
public final class DataController {
    
    public static let shared = DataController()

    public let container: NSPersistentContainer

    public var context: NSManagedObjectContext { container.viewContext }

    public init(inMemory: Bool = false) {
        guard let modelURL = Bundle.module.url(forResource: "iSucurgal", withExtension: "momd") else {
            fatalError("🛑 No encontré iSucurgal.momd en Bundle.module. Asegurate de mover iSucurgal.xcdatamodeld a Sources/LocationRegisterKit/Resources/")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("🛑 No pude crear NSManagedObjectModel desde: \(modelURL)")
        }

        container = NSPersistentContainer(name: "iSucurgal", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Error al cargar Core Data: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    public func saveContext() throws {
        let ctx = container.viewContext
        if ctx.hasChanges {
            try ctx.save()
        }
    }
}

public extension DataController {
    static var preview: DataController = {
        let controller = DataController(inMemory: true)
        return controller
    }()
}
