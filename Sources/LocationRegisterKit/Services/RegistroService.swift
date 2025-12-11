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

    func getRegistrosFromAPI() async throws -> [Registro] {
        let dtos = try await api.fetchRegistros()
        
        let container = NSPersistentContainer(name: "LocationRegisterKit")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
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
        let registrosInMemory = dtos.map { dto in
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
