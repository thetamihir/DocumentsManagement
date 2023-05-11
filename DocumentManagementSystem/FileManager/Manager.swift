//
//  Manager.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 10/05/23.
//

import Foundation


class Manager {
    var copyurls = [URL]()
    var directoryUrls = [URL]()
    static let share = Manager()
    
    var documentsDirectoryURL: URL {
           return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
       }
    
    func createDirectory(name : String , complation : (Bool) -> Void){
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let directoryURL = documentsDirectory.appendingPathComponent(name)
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true , attributes: nil)
            complation(true)
        } catch  {
          complation(false)
        }
    }
    
    func getDirectory() -> [URL] {
        do {
            directoryUrls = try FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
        } catch {
            print(error.localizedDescription)
        }
        return directoryUrls
    }

    
    func Delelte(url : URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch  {
            print(error)
        }
    }
    
    
    func storeDirectory() {
        directoryUrls = getDirectory()
    }
}
