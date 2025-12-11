//
//  SucursalService.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation

@MainActor
final class SucursalService {
    private let repository = SucursalRepository()
    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIServiceRender()) {
        self.api = api
    }

    func loadFromJSON(resourceName: String = "sucursales") async throws {
        guard let url = Bundle.module.url(forResource: resourceName, withExtension: "json") else {
            throw NSError(domain: "SucursalService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Resource not found"])
        }

        let data = try Data(contentsOf: url)
        let dtos = try JSONDecoder().decode([SucursalDTO].self, from: data)
        try repository.saveSucursales(dtos)
    }

    func fetchFromAPIAndSave() async throws {
        let dtos = try await api.fetchSucursales()

        guard !dtos.isEmpty else {
            throw NSError(domain: "API", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "API devolvió vacío"])
        }

        try repository.saveSucursales(dtos)
    }

    func clearAll() throws {
        try repository.clearAll()
    }

    func fetchLocal() throws -> [Sucursal] {
        try repository.getAll()
    }
}
