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

    public func receiveSucursalesFromModule(_ sucursales: [Sucursal]) {
        guard !sucursales.isEmpty else { return }

        if manager.authorizationStatus != .authorizedAlways {
            print("🟡 [GEOFENCE] No tengo AUTH ALWAYS → guardo sucursales en pending")
            pendingSucursales = sucursales
            return
        }

        setupGeofences(for: sucursales)
    }

    public func setupGeofences(for sucursales: [Sucursal]) {
        guard !sucursales.isEmpty else { return }
        guard manager.authorizationStatus == .authorizedAlways else {
            pendingSucursales = sucursales
            return
        }

        // Limpiar geofences actuales
        for r in manager.monitoredRegions {
            manager.stopMonitoring(for: r)
        }
        monitoredRegions.removeAll()

        for suc in sucursales {
            let center = CLLocationCoordinate2D(latitude: suc.latitude, longitude: suc.longitude)
            let region = CLCircularRegion(center: center, radius: 80, identifier: suc.id.uuidString)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            manager.startMonitoring(for: region)
            monitoredRegions.append(region)
            print("🟦 [GEOFENCE] Monitoreando → \(region.identifier)")
        }
    }
}



// MARK: - CLLocationManagerDelegate
extension GeofencingManager: CLLocationManagerDelegate {

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        Task { @MainActor in
            print("🛂 [GEOFENCE] Authorization cambió → \(status.rawValue)")
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        let id = region.identifier

        Task { @MainActor in
            if self.isAppActive {
                print("⚠️ [GEOFENCE] didEnter ignorado (foreground): \(id)")
                return
            }

            print("🟩 [GEOFENCE] ENTREEE → region: \(id)")

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

            print("🟥 [GEOFENCE] SAAALIII → region: \(id)")

            guard let uuid = UUID(uuidString: id) else { return }
            self.registroManager?.registrarSalida(sucursalID: uuid)
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager,
                                            monitoringDidFailFor region: CLRegion?,
                                            withError error: Error) {

        let msg = error.localizedDescription
        let id = region?.identifier

        Task { @MainActor in
            if let id {
                print("❌ [GEOFENCE] ERROR en región \(id): \(msg)")
            } else {
                print("❌ [GEOFENCE] ERROR:", msg)
            }
        }
    }
}


// MARK: - Simulaciones
extension GeofencingManager {

    public func simulateEnter(regionID: UUID) {
        print("🟩 [SIM] simulateEnter → \(regionID)")
        registroManager?.registrarEntrada(sucursalID: regionID)
    }

    public func simulateExit(regionID: UUID) {
        print("🟥 [SIM] simulateExit → \(regionID)")
        registroManager?.registrarSalida(sucursalID: regionID)
    }
}
