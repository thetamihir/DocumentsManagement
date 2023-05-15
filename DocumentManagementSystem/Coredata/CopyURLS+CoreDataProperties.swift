//
//  CopyURLS+CoreDataProperties.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 15/05/23.
//
//

import Foundation
import CoreData


extension CopyURLS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CopyURLS> {
        return NSFetchRequest<CopyURLS>(entityName: "CopyURLS")
    }

    @NSManaged public var copyurls: String?

}

extension CopyURLS : Identifiable {

}
