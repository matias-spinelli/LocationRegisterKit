//
//  RegistroDTO.swift
//  iSucurgal
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation

public struct RegistroDTO: Identifiable, Codable {
    public var id: UUID
    public var timestamp: Date
    public var tipo: RegistroType
    public var sucursalID: UUID
    public var userID: UUID
}

public enum RegistroType: String, Codable {
    case entrada
    case salida
}

extension Registro {
    public var tipoEnum: RegistroType {
        return RegistroType(rawValue: tipo) ?? .entrada
    }
}
