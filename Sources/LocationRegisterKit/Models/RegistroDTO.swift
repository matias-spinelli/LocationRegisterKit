//
//  RegistroDTO.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation
import CryptoKit

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

    public init(id: UUID, timestamp: Date, tipo: RegistroType, sucursalID: UUID, userID: UUID) {
        self.id = id
        self.timestamp = timestamp
        self.tipo = tipo
        self.sucursalID = sucursalID
        self.userID = userID
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(uuidToObjectIdString(id), forKey: .id)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let timestampString = isoFormatter.string(from: timestamp)
        try container.encode(timestampString, forKey: .timestamp)

        try container.encode(tipo, forKey: .tipo)
//        try container.encode(uuidToObjectIdString(sucursalID), forKey: .sucursalID)
//        try container.encode(uuidToObjectIdString(userID), forKey: .userID)
        try container.encode(sucursalID.uuidString, forKey: .sucursalID)
        try container.encode(userID.uuidString, forKey: .userID)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        let idString = try container.decode(String.self, forKey: .id)
        guard let id = objectIdStringToUUID(idString) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "ObjectId string inválido para id"))
        }
        self.id = id

        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let timestamp = isoFormatter.date(from: timestampString) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Timestamp ISO8601 inválido"))
        }
        self.timestamp = timestamp

        self.tipo = try container.decode(RegistroType.self, forKey: .tipo)

        let sucursalString = try container.decode(String.self, forKey: .sucursalID)
        let userString = try container.decode(String.self, forKey: .userID)
        guard let sucursalID = UUID(uuidString: sucursalString),
              let userID = UUID(uuidString: userString) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "UUID string inválido para sucursalID o userID"))
        }
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

// MARK: - Helpers

fileprivate func uuidToObjectIdString(_ uuid: UUID) -> String {
    // Convertimos UUID -> 12 bytes -> hex string (24 chars)
    let bytes = uuid.uuid
    return String(format: "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                  bytes.0, bytes.1, bytes.2, bytes.3,
                  bytes.4, bytes.5, bytes.6, bytes.7,
                  bytes.8, bytes.9, bytes.10, bytes.11)
}

fileprivate func objectIdStringToUUID(_ string: String) -> UUID? {
    guard string.count == 24 else { return nil }
    // tomamos 16 bytes del ObjectId para crear UUID
    let hex = string.prefix(32)  // completamos si es necesario (o hash)
    var uuidBytes = [UInt8](repeating: 0, count: 16)
    for i in 0..<16 {
        let start = hex.index(hex.startIndex, offsetBy: i*2)
        let end = hex.index(start, offsetBy: 2)
        let byteStr = hex[start..<end]
        uuidBytes[i] = UInt8(byteStr, radix: 16) ?? 0
    }
    return UUID(uuid: (
        uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
        uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
        uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
        uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
    ))
}
