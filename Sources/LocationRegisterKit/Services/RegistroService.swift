//
//  RegistroService.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 06/12/2025.
//

import Foundation
import CoreData

@MainActor
final class RegistroService {

    private let repository = RegistroRepository()
    private let api: APIServiceRender

    init(api: APIServiceRender = APIServiceRender()) {
        self.api = api
    }
    
    func getLocalRegistros() throws -> [Registro] {
        try repository.getAll()
    }

    public func getRegistrosFromAPI() async throws -> [Registro] {
        // 1️⃣ Traemos los DTOs de la API
        let dtos = try await api.fetchRegistros()

        // 2️⃣ Creamos el contenedor en memoria
        let container = NSPersistentContainer(name: "LocationRegisterKit")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        // 3️⃣ Cargamos persistent store de forma segura
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        let context = container.viewContext

        // 4️⃣ Mapeamos los DTOs a NSManagedObjects
        let registrosInMemory = dtos.map { dto -> Registro in
            let registro = Registro(context: context)
            registro.id = dto.id
            registro.timestamp = dto.timestamp
            registro.tipo = dto.tipo.rawValue
            registro.sucursalID = dto.sucursalID
            registro.userID = dto.userID
            return registro
        }

        return registrosInMemory
    }

    
    func crearRegistro(sucursalID: UUID, tipo: RegistroType) throws {
        let dto = RegistroDTO(
            id: UUID(),
            timestamp: Date(),
            tipo: tipo,
            sucursalID: sucursalID,
            userID: AppUser.id
        )
        try repository.add(dto)
    }

    func crearRegistroAPI(sucursalID: UUID, tipo: RegistroType) async throws -> RegistroDTO {
        let dto = RegistroDTO(
            id: UUID(),
            timestamp: Date(),
            tipo: tipo,
            sucursalID: sucursalID,
            userID: AppUser.id
        )
        return try await api.createRegistro(dto)
    }
    
    func getPorSucursal(_ id: UUID) throws -> [Registro] {
        try repository.getBySucursal(id)
    }
    
    func clearAll() throws {
        try repository.clearAll()
    }
}
