//
//  RegistroManager.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 07/12/2025.
//

import Foundation
import CoreLocation
import Combine

@MainActor
public final class RegistroManager: ObservableObject {

    @Published private(set) var currentSucursalID: UUID? = nil

    let registroViewModel: RegistroViewModel
    let sucursalesViewModel: SucursalesViewModel

    private let detectionRadius: Double
    private let minInterval: TimeInterval

    private var lastEventDate: Date = .distantPast
    private var sucursalLocations: [(id: UUID, name: String, location: CLLocation)] = []

    private var lastValidLocation: CLLocation?

    init(
        registroViewModel: RegistroViewModel,
        sucursalesViewModel: SucursalesViewModel,
        detectionRadius: Double = 50,
        minInterval: TimeInterval = 10
    ) {
        self.registroViewModel = registroViewModel
        self.sucursalesViewModel = sucursalesViewModel
        self.detectionRadius = detectionRadius
        self.minInterval = minInterval

        rebuildCache()
    }

    func rebuildCache() {
        sucursalLocations = sucursalesViewModel.sucursales.map { sucursal in
            (
                id: sucursal.id,
                name: sucursal.name,
                location: CLLocation(latitude: sucursal.latitude,
                                     longitude: sucursal.longitude)
            )
        }
        print("🗺️ Cache reconstruido: \(sucursalLocations.count) sucursales")
    }

    func processLocation(_ userLocation: CLLocation) {

        print("\n📍 Nueva ubicación:")
        print("   Lat: \(userLocation.coordinate.latitude)")
        print("   Lon: \(userLocation.coordinate.longitude)")
        print("   Precisión: \(Int(userLocation.horizontalAccuracy))m")

        if userLocation.horizontalAccuracy < 0 || userLocation.horizontalAccuracy > 50 {
            print("🔇 Ubicación ignorada → mala precisión (\(userLocation.horizontalAccuracy)m)")
            return
        }

        let now = Date()

        lastValidLocation = userLocation

        print("   currentSucursalID (UI) = \(currentSucursalID?.uuidString ?? "NINGUNO")")

        guard !sucursalLocations.isEmpty else {
            print("⚠️ No hay sucursales cargadas → NO se procesa ubicación")
            return
        }

        if let insideID = currentSucursalID,
           let entry = sucursalLocations.first(where: { $0.id == insideID }) {

            let dist = userLocation.distance(from: entry.location)
            print("   ↔️ Distancia a sucursal actual (\(entry.name)): \(Int(dist))m")

            // Salida
            if dist > detectionRadius {
                print("⬅️ SALIDA registrada de \(entry.name)")
                registroViewModel.registrar(tipo: .salida, sucursalID: insideID)

                currentSucursalID = nil
                lastEventDate = now

                checkImmediateEntry(from: userLocation, now: now)
                return
            }

            print("🟢 Seguís dentro de \(entry.name). No se registra nada.")
            return
        }

        if now.timeIntervalSince(lastEventDate) < minInterval {
            print("⏳ Ignorado por minInterval (\(Int(minInterval))s)")
            return
        }

        tryRegisterEntry(from: userLocation, now: now)
    }

    // MARK: - Helpers

    private func tryRegisterEntry(from userLocation: CLLocation, now: Date) {
        for entry in sucursalLocations {
            let dist = userLocation.distance(from: entry.location)
            print("   ↔️ Distancia a \(entry.name): \(Int(dist))m")

            if dist <= detectionRadius {
                print("➡️ ENTRADA registrada en \(entry.name)")
                registroViewModel.registrar(tipo: .entrada, sucursalID: entry.id)

                currentSucursalID = entry.id
                lastEventDate = now
                return
            }
        }

        print("🟡 Fuera de todas y no estabas dentro → Nada que hacer")
    }

    private func checkImmediateEntry(from userLocation: CLLocation, now: Date) {
        for entry in sucursalLocations {
            let dist = userLocation.distance(from: entry.location)
            print("   (post-salida) Dist a \(entry.name): \(Int(dist))m")

            if dist <= detectionRadius {
                print("➡️ ENTRADA registrada (post-salida) en \(entry.name)")
                registroViewModel.registrar(tipo: .entrada, sucursalID: entry.id)

                currentSucursalID = entry.id
                lastEventDate = now
                return
            }
        }

        print("🟡 (post-salida) No hay entrada inmediata.")
    }

    func registrarEntrada(sucursalID: UUID) {
        let now = Date()

        if currentSucursalID == sucursalID {
            print("⚠️ Ignorado registrarEntrada: ya dentro de \(sucursalID)")
            return
        }

        if now.timeIntervalSince(lastEventDate) < minInterval {
            print("⚠️ Ignorado registrarEntrada: minInterval no expirado")
            return
        }

        print("📥 registrarEntrada (geofence/sim) para \(sucursalID)")
        registroViewModel.registrar(tipo: .entrada, sucursalID: sucursalID)
        currentSucursalID = sucursalID
        lastEventDate = now
    }

    func registrarSalida(sucursalID: UUID) {
        let now = Date()

        if currentSucursalID != sucursalID {
            print("⚠️ Ignorado registrarSalida: currentSucursalID != \(sucursalID)")
            return
        }

        if now.timeIntervalSince(lastEventDate) < minInterval {
            print("⚠️ Ignorado registrarSalida: minInterval no expirado")
            return
        }

        print("📤 registrarSalida (geofence/sim) para \(sucursalID)")
        registroViewModel.registrar(tipo: .salida, sucursalID: sucursalID)
        currentSucursalID = nil
        lastEventDate = now
    }
}
