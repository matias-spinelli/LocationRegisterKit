//
//  SucursalService.swift
//  iSucurgal
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation

@MainActor
final class SucursalService {
    private let repo = SucursalRepository()
    private let api: APIServiceProtocol

    init(api: APIServiceProtocol = APIServiceMock()) {
        self.api = api
    }

    func loadFromJSON(resourceName: String = "sucursales") async throws {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            throw NSError(domain: "SucursalService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Resource not found"])
        }

        let data = try Data(contentsOf: url)
        let dtos = try JSONDecoder().decode([SucursalDTO].self, from: data)
        try repo.saveSucursales(dtos)
    }

    func fetchFromAPIAndSave() async throws {
        let dtos = try await api.fetchSucursalesAsync()

        guard !dtos.isEmpty else {
            throw NSError(domain: "API", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "API devolvió vacío"])
        }

        try repo.saveSucursales(dtos)
    }

    func clearAll() throws {
        try repo.clearAll()
    }

    func fetchLocal() throws -> [Sucursal] {
        try repo.getAll()
    }
}
