//
//  RegistroRepository.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation
import CoreData

@MainActor
final class RegistroRepository {
    
    private let context = DataController.shared.context

    func add(_ dto: RegistroDTO) throws {
        let entity = Registro(context: context)
        entity.id = dto.id
        entity.timestamp = dto.timestamp
        entity.tipo = dto.tipo.rawValue
        entity.sucursalID = dto.sucursalID
        entity.userID = dto.userID
        try context.save()
    }

    func getAll() throws -> [Registro] {
        let request: NSFetchRequest<Registro> = Registro.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]
        return try context.fetch(request)
    }

    func getBySucursal(_ id: UUID) throws -> [Registro] {
        let request: NSFetchRequest<Registro> = Registro.fetchRequest()
        request.predicate = NSPredicate(format: "sucursalID == %@", id as CVarArg)
        return try context.fetch(request)
    }

    func clearAll() throws {
        let fetch: NSFetchRequest<NSFetchRequestResult> = Registro.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)
        try context.execute(delete)
        try context.save()
    }
}
