//
//  RegistroViewModel.swift
//  iSucurgal
//
//  Created by Matías Spinelli on 06/12/2025.
//

import Foundation
import Combine

@MainActor
public final class RegistroViewModel: ObservableObject {

    @Published var registros: [Registro] = []
    @Published public var errorMessage: String?

    private let service = RegistroService()

    func cargarRegistros() {
        do {
            registros = try service.getHistorial()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func registrar(tipo: RegistroType, sucursalID: UUID) {
        do {
            try service.crearRegistro(sucursalID: sucursalID, tipo: tipo)
            cargarRegistros()
        } catch {
            errorMessage = error.localizedDescription
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
