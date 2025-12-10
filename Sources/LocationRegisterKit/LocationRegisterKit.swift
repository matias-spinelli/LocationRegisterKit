//
//  LocationRegisterKitModule.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 09/12/2025.
//

import Foundation
import CoreLocation
import Combine
import UIKit

@MainActor
public final class LocationRegisterKitModule {

    public static let shared = LocationRegisterKitModule()
    
    private var cancellables = Set<AnyCancellable>()

    private let _registroManager: RegistroManager
    private let _locationManager: LocationManager
    private let _geofencingManager: GeofencingManager

    public var registroManager: RegistroManager { _registroManager }
    public var locationManager: LocationManager { _locationManager }
    public var geofencingManager: GeofencingManager { _geofencingManager }

    public var sucursalesViewModel: SucursalesViewModel {
        _registroManager.sucursalesViewModel
    }

    public var registroViewModel: RegistroViewModel {
        _registroManager.registroViewModel
    }

    private init() {
        let suc = SucursalesViewModel()
        let reg = RegistroViewModel()
        let rManager = RegistroManager(registroViewModel: reg, sucursalesViewModel: suc)

        _registroManager = rManager
        _locationManager = LocationManager()
        _geofencingManager = GeofencingManager()

        _locationManager.registroManager = rManager
        _geofencingManager.registroManager = rManager
    }

    public func startModule() {
        observeSucursales()
        observeLifecycle()

        registroManager.sucursalesViewModel.cargarSucursales()
        registroManager.rebuildCache()

        locationManager.requestAuthorization()
        locationManager.start()
    }

    private func observeSucursales() {
        registroManager.sucursalesViewModel.$sucursales
            .sink { [weak self] nuevas in
                guard let self = self else { return }
                guard !nuevas.isEmpty else { return }

                print("📍 Sucursales listas → pasando a GeofencingManager")
                self.geofencingManager.receiveSucursalesFromModule(nuevas)
            }
            .store(in: &cancellables)
    }

    private func observeLifecycle() {
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.locationManager.enterBackground()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.locationManager.enterForeground()
            }
            .store(in: &cancellables)
    }

    public func registrarEntrada(_ id: UUID) {
        registroManager.registrarEntrada(sucursalID: id)
    }

    public func registrarSalida(_ id: UUID) {
        registroManager.registrarSalida(sucursalID: id)
    }
}
