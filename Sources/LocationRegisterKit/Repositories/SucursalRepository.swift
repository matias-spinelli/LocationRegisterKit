//
//  SucursalRepository.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation
import CoreData

@MainActor
final class SucursalRepository {

    private let context = DataController.shared.context

    func saveSucursales(_ list: [SucursalDTO]) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Sucursal.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(batchDelete)

        for dto in list {
            let entity = Sucursal(context: context)
            entity.id = dto.id
            entity.name = dto.name
            entity.address = dto.address
            entity.latitude = dto.latitude
            entity.longitude = dto.longitude
        }
        try context.save()
    }

    func getAll() throws -> [Sucursal] {
        let request: NSFetchRequest<Sucursal> = Sucursal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try context.fetch(request)
    }

    func clearAll() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Sucursal.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(batchDelete)
        try context.save()
    }
}
