//
//  SucursalesViewModel.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation
import Combine

@MainActor
public final class SucursalesViewModel: ObservableObject {
    @MainActor @Published public var sucursales: [Sucursal] = []
    @MainActor @Published public var isLoading: Bool = false
    @MainActor @Published public var errorMessage: String?

    private let service: SucursalService

    init(service: SucursalService = SucursalService()) {
        self.service = service
    }

    @MainActor
    public func cargarSucursales() {
        print("cargarSucursales")

        isLoading = true
        errorMessage = nil

        do {
            let locales = try service.fetchLocal()

            if !locales.isEmpty {
                self.sucursales = locales
                self.isLoading = false
                return
            }

        } catch {
            print("Error cargando CoreData: \(error.localizedDescription)")
        }
        
        traerDesdeAPI()
    }
    
    private func traerDesdeAPI() {
        print("traerDesdeAPI")

        Task { @MainActor in
            do {
                try await service.fetchFromAPIAndSave()
                self.cargarDesdeCoreData()
                self.isLoading = false

            } catch {
                print("API falló, fallback al JSON \(error.localizedDescription)")
                cargarDesdeJSON()
            }
        }
    }

    private func cargarDesdeJSON() {
        print("cargarDesdeJSON")

        Task { @MainActor in
            do {
                try await service.loadFromJSON()
                self.cargarDesdeCoreData()
                self.isLoading = false

            } catch {
                print("No hay sucursales disponibles.\n\(error.localizedDescription)")
                self.errorMessage = "No hay sucursales disponibles.\n\(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    @MainActor func cargarDesdeCoreData() {
        do {
            self.sucursales = try service.fetchLocal()

            if self.sucursales.isEmpty {
                self.errorMessage = "No hay sucursales disponibles."
            }

        } catch {
            self.errorMessage = "Error cargando CoreData: \(error.localizedDescription)"
        }
    }
    
    @MainActor public func clearAll() {
        do {
            try service.clearAll()
            self.sucursales = []
            print("✔️ Sucursales borradas correctamente")
        } catch {
            self.errorMessage = "No se pudo borrar sucursales: \(error.localizedDescription)"
        }
    }
}

extension SucursalesViewModel {
    func nombreDeSucursal(id: UUID) -> String? {
        sucursales.first(where: { $0.id == id })?.name
    }
}
