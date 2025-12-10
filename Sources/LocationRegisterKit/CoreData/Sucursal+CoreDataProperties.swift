//
//  Sucursal+CoreDataProperties.swift
//  iSucurgal
//
//  Created by Matías Spinelli on 05/12/2025.
//

import Foundation
import CoreData

extension Sucursal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sucursal> {
        return NSFetchRequest<Sucursal>(entityName: "Sucursal")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var address: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
}

extension Sucursal: Identifiable { }
