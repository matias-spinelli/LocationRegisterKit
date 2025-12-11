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

    public func getRegistrosFromAPI() async throws -> [RegistroDTO] {
        let registros = try await api.fetchRegistros()
        return registros
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
