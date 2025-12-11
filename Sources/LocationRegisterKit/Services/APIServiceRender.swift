//
//  APIServiceRender.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 11/12/2025.
//

import Foundation

final class APIServiceRender: APIServiceProtocol {
    
    private let baseURL = "https://locationregisterapi.onrender.com/api"

    func fetchSucursales() async throws -> [SucursalDTO] {
        guard let url = URL(string: "\(baseURL)/sucursales") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let dtos = try JSONDecoder().decode([SucursalDTO].self, from: data)
        return dtos
    }
    
    func fetchRegistros() async throws -> [RegistroDTO] {
        guard let url = URL(string: "\(baseURL)/registros") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let dtos = try JSONDecoder().decode([RegistroDTO].self, from: data)
        return dtos
    }
    
    @MainActor
    func createRegistro(_ registro: RegistroDTO) async throws -> RegistroDTO {
        guard let url = URL(string: "\(baseURL)/registros") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let data = try JSONEncoder().encode(registro)
        request.httpBody = data

        let (responseData, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let savedRegistro = try JSONDecoder().decode(RegistroDTO.self, from: responseData)
        return savedRegistro
    }
}
