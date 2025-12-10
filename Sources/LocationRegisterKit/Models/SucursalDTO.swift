//
//  SucursalDTO.swift
//  iSucurgal
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation

public struct SucursalDTO: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var address: String
    public var latitude: Double
    public var longitude: Double
}
