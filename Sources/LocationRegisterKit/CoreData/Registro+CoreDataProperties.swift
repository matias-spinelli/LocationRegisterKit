//
//  Registro+CoreDataProperties.swift
//  LocationRegisterKit
//
//  Created by Matías Spinelli on 06/12/2025.
//

import Foundation
import CoreData

extension Registro {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Registro> {
        return NSFetchRequest<Registro>(entityName: "Registro")
    }

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var tipo: String
    @NSManaged public var sucursalID: UUID
    @NSManaged public var userID: UUID
}

extension Registro: Identifiable { }
