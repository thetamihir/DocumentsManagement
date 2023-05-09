//
//  Directory+CoreDataProperties.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 09/05/23.
//
//

import Foundation
import CoreData


extension Directory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Directory> {
        return NSFetchRequest<Directory>(entityName: "Directory")
    }

    @NSManaged public var name: String?

}

extension Directory : Identifiable {

}
