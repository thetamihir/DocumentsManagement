//
//  CopyURLS+CoreDataProperties.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 17/05/23.
//
//

import Foundation
import CoreData


extension CopyURLS {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CopyURLS> {
        return NSFetchRequest<CopyURLS>(entityName: "CopyURLS")
    }

    @NSManaged public var copyurls: String?
    @NSManaged public var urlsize: Int64

}

extension CopyURLS : Identifiable {

}
