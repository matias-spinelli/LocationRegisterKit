//
//  APIServiceMock.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation

public protocol APIServiceProtocol: Sendable {
    func fetchSucursales() async throws -> [SucursalDTO]
}

public final class APIServiceMock: APIServiceProtocol {
    private let bundle: Bundle

    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    public func fetchSucursales() async throws -> [SucursalDTO] {
        return []
    }
}
