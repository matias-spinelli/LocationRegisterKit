//
//  RegistroViewModel.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 06/12/2025.
//

import Foundation
import Combine

@MainActor
public final class RegistroViewModel: ObservableObject {

    @Published public var registros: [Registro] = []
    @Published public var registrosAPI: [Registro] = []
    @Published public var errorMessage: String?

    private let service = RegistroService()

    public func getRegistrosFromCoreData() {
        do {
            registros = try service.getLocalRegistros()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func getRegistrosFromAPI() async {
        do {
            registrosAPI = try await service.getRegistrosFromAPI()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error fetching registros: \(error)")
        }
    }

    func registrar(tipo: RegistroType, sucursalID: UUID) {
        do {
            try service.crearRegistro(sucursalID: sucursalID, tipo: tipo)
            getRegistrosFromCoreData()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        Task { [weak self] in
            do {
                let _ = try await self?.service.crearRegistroAPI(sucursalID: sucursalID, tipo: tipo)
                await self?.getRegistrosFromAPI()
            } catch {
                print("⚠️ Error enviando al backend: \(error)")
            }
        }
    }

    public func clearAll() {
        do {
            try service.clearAll()
            registros = []
            print("✔️ Registros borrados")
        } catch {
            errorMessage = "Error borrando registros: \(error.localizedDescription)"
        }
    }
    
    func registrarEntrada(sucursalID: UUID) {
        registrar(tipo: .entrada, sucursalID: sucursalID)
    }

    func registrarSalida(sucursalID: UUID) {
        registrar(tipo: .salida, sucursalID: sucursalID)
    }
}
