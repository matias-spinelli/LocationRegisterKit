//
//  LocationRegisterKitModule.swift
//  LocationRegisterKit
//
//  Created by ChatGPT “Michu” on 09/12/2025.
//

import Foundation
import CoreLocation
import Combine

@MainActor
public final class LocationRegisterKitModule {

    public static let shared = LocationRegisterKitModule()

    public let registroManager: RegistroManager
    public let locationManager: LocationManager
    public let geofencingManager: GeofencingManager

    private init() {
        let sucVm = SucursalesViewModel()
        let regVm = RegistroViewModel()

        registroManager = RegistroManager(
            registroViewModel: regVm,
            sucursalesViewModel: sucVm
        )

        locationManager = LocationManager()
        geofencingManager = GeofencingManager()

        locationManager.registroManager = registroManager
        geofencingManager.registroManager = registroManager
    }

    // MARK: - Public API

    public func startModule() {
        locationManager.requestAuthorization()
        locationManager.start()
    }

    public func registrarEntrada(_ id: UUID) {
        registroManager.registrarEntrada(sucursalID: id)
    }

    public func registrarSalida(_ id: UUID) {
        registroManager.registrarSalida(sucursalID: id)
    }

    // MARK: - JSON async/await

    public func loadSucursalesFromJSON() async {
        do {
            try await SucursalService().loadFromJSON()
        } catch {
            print("❌ Error cargando sucursales JSON: \(error)")
        }
    }

    // MARK: - CoreData cleanup

    public func clearSucursalesCoreData() {
        do {
            try SucursalRepository().clearAll()
        } catch {
            print("❌ Error borrando sucursales CoreData: \(error)")
        }
    }

    public func clearRegistrosCoreData() {
        do {
            try RegistroRepository().clearAll()
        } catch {
            print("❌ Error borrando registros CoreData: \(error)")
        }
    }
}
