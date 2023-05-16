//
//  File.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 16/05/23.
//

import Foundation

class Constants {
     // set limit of storage
    static let storageLimit = (1024 * 1024 * 1024)/4
    
    // storedirectory url
    static var documentsDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
