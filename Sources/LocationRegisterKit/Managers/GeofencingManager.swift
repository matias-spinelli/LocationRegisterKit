//
//  GeofencingManager.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 08/12/2025.
//

import Foundation
import CoreLocation
import Combine

@MainActor
public final class GeofencingManager: NSObject, ObservableObject {

    private let manager = CLLocationManager()
    public weak var registroManager: RegistroManager?

    @Published public var isAppActive: Bool = true
    @Published public var monitoredRegions: [CLCircularRegion] = []

    private var pendingSucursales: [Sucursal] = []

    public override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - ENTRY POINT DESDE EL MÓDULO

    public func receiveSucursalesFromModule(_ sucursales: [Sucursal]) {
        guard !sucursales.isEmpty else { return }

        let status = manager.authorizationStatus

        if status != .authorizedAlways {
            print("🟡 [GEOFENCE] AUTH no disponible → guardo sucursales en pending")
            pendingSucursales = sucursales
            return
        }

        setupGeofences(for: sucursales)
    }

    // MARK: - Configurar geofences

    public func setupGeofences(for sucursales: [Sucursal]) {

        if manager.authorizationStatus != .authorizedAlways {
            print("🔴 [GEOFENCE] setupGeofences llamado SIN AUTH (se guardan en pending)")
            pendingSucursales = sucursales
            return
        }

        if !manager.monitoredRegions.isEmpty {
            for r in manager.monitoredRegions {
                manager.stopMonitoring(for: r)
            }
        }

        monitoredRegions.removeAll()

        for suc in sucursales {
            let center = CLLocationCoordinate2D(
                latitude: suc.latitude,
                longitude: suc.longitude
            )

            let region = CLCircularRegion(
                center: center,
                radius: 80,
                identifier: suc.id.uuidString
            )

            region.notifyOnEntry = true
            region.notifyOnExit = true

            manager.startMonitoring(for: region)
            monitoredRegions.append(region)

            print("🟦 [GEOFENCE] Monitoreando → \(region.identifier)")
        }
    }
}

// MARK: - LOCATION DELEGATE

extension GeofencingManager: CLLocationManagerDelegate {

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        Task { @MainActor in
            print("🛂 [GEOFENCE] Authorization cambió → \(status.rawValue)")

            if status == .authorizedAlways, !self.pendingSucursales.isEmpty {
                print("🟢 [GEOFENCE] Ahora tengo AUTH ALWAYS → aplico pending sucursales")
                let pendientes = self.pendingSucursales
                self.pendingSucursales.removeAll()
                self.setupGeofences(for: pendientes)
            }
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        let id = region.identifier

        Task { @MainActor in
            if self.isAppActive {
                print("⚠️ [GEOFENCE] didEnter ignorado (foreground): \(id)")
                return
            }

            print("🟩 [GEOFENCE] ENTREEE → \(id)")

            guard let uuid = UUID(uuidString: id) else { return }
            self.registroManager?.registrarEntrada(sucursalID: uuid)
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

        let id = region.identifier

        Task { @MainActor in
            if self.isAppActive {
                print("⚠️ [GEOFENCE] didExit ignorado (foreground): \(id)")
                return
            }

            print("🟥 [GEOFENCE] SAAALIII → \(id)")

            guard let uuid = UUID(uuidString: id) else { return }
            self.registroManager?.registrarSalida(sucursalID: uuid)
        }
    }
}
