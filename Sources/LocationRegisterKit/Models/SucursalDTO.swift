//
//  SucursalDTO.swift
//  LocationRegisterKit
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
        let idString = try container.decode(String.self, forKey: .id)
        guard let uuid = UUID(uuidString: idString) else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container,
                debugDescription: "ID no es un UUID válido")
        }
        self.id = uuid
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decode(String.self, forKey: .address)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }
}
