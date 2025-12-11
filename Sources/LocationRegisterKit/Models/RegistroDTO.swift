//
//  RegistroDTO.swift
//  LocationRegisterKit
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case tipo
        case sucursalID
        case userID
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(tipo, forKey: .tipo)
        try container.encode(sucursalID.uuidString, forKey: .sucursalID)
        try container.encode(userID.uuidString, forKey: .userID)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        let sucursalString = try container.decode(String.self, forKey: .sucursalID)
        let userString = try container.decode(String.self, forKey: .userID)
        
        guard let id = UUID(uuidString: idString),
              let sucursalID = UUID(uuidString: sucursalString),
              let userID = UUID(uuidString: userString)
        else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                   debugDescription: "UUID string inválido"))
        }
        
        self.id = id
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.tipo = try container.decode(RegistroType.self, forKey: .tipo)
        self.sucursalID = sucursalID
        self.userID = userID
    }
    
    public init(id: UUID, timestamp: Date, tipo: RegistroType, sucursalID: UUID, userID: UUID) {
        self.id = id
        self.timestamp = timestamp
        self.tipo = tipo
        self.sucursalID = sucursalID
        self.userID = userID
    }
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
