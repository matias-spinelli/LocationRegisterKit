//
//  LocationManager.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 06/12/2025.
//

import Foundation
import CoreLocation
import Combine

@MainActor
public final class LocationManager: NSObject, ObservableObject {

    private let manager = CLLocationManager()

    @Published public var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?

    weak var registroManager: RegistroManager?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest

        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    func requestAuthorization() {
        print("📍 Solicitando autorización ALWAYS…")
        manager.requestAlwaysAuthorization()
    }

    func start() {
        print("🚀 LocationManager.start()")
        manager.startMonitoringSignificantLocationChanges()
        manager.startUpdatingLocation()
    }

    func stop() {
        print("🛑 LocationManager.stop()")
        manager.stopUpdatingLocation()
    }

    func enterForeground() {
        print("☀️ App volvió a FOREGROUND → Reactivamos GPS preciso")
        start()
    }

    func enterBackground() {
        print("🌙 App pasó a BACKGROUND → Desactivamos GPS preciso")
        stop()
    }
}

// MARK: - Delegate
extension LocationManager: CLLocationManagerDelegate {

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        switch status {
        case .authorizedAlways:
            manager.startUpdatingLocation()
            manager.startMonitoringSignificantLocationChanges()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }

        Task { @MainActor in
            self.authorizationStatus = status
            print("🛂 [LOC] Authorization:", status.rawValue)
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let loc = locations.last else { return }

        Task { @MainActor in
            print("📍 [LOC] Update:", loc.coordinate)
            self.userLocation = loc
            self.registroManager?.processLocation(loc)
        }
    }
}
