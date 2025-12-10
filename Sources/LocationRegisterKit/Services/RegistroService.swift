//
//  RegistroService.swift
//  iSucurgal
//
//  Created by Matías Spinelli on 06/12/2025.
//

import Foundation

@MainActor
final class RegistroService {

    private let repo = RegistroRepository()

    func crearRegistro(sucursalID: UUID, tipo: RegistroType) throws {
        let dto = RegistroDTO(
            id: UUID(),
            timestamp: Date(),
            tipo: tipo,
            sucursalID: sucursalID,
            userID: AppUser.id
        )
        try repo.add(dto)
    }

    func getHistorial() throws -> [Registro] {
        try repo.getAll()
    }

    func getPorSucursal(_ id: UUID) throws -> [Registro] {
        try repo.getBySucursal(id)
    }
    
    func clearAll() throws {
        try repo.clearAll()
    }
}
