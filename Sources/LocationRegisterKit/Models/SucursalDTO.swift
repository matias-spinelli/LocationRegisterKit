//
//  SucursalDTO.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation
import CryptoKit

public struct SucursalDTO: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var address: String
    public var latitude: Double
    public var longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case latitude
        case longitude
    }
    public init(id: UUID, name: String, address: String, latitude: Double, longitude: Double) {
         self.id = id
         self.name = name
         self.address = address
         self.latitude = latitude
         self.longitude = longitude
     }
    
    public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(id.uuidString, forKey: .id)
          try container.encode(name, forKey: .name)
          try container.encode(address, forKey: .address)
          try container.encode(latitude, forKey: .latitude)
          try container.encode(longitude, forKey: .longitude)
      }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Convertimos el ObjectId a un UUID consistente
        let idString = try container.decode(String.self, forKey: .id)
        let hash = SHA256.hash(data: Data(idString.utf8))
        let hashBytes = Array(hash)
        
        let uuid = UUID(uuid: (
            hashBytes[0], hashBytes[1], hashBytes[2], hashBytes[3],
            hashBytes[4], hashBytes[5], hashBytes[6], hashBytes[7],
            hashBytes[8], hashBytes[9], hashBytes[10], hashBytes[11],
            hashBytes[12], hashBytes[13], hashBytes[14], hashBytes[15]
        ))
        self.id = uuid

        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decode(String.self, forKey: .address)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }

}
