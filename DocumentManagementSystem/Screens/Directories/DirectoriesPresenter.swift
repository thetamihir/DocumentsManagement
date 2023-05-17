//
//  Manager.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 10/05/23.
//

import Foundation
import CoreData

class DirectoriesPresenter {
    
    var copyurls = [URL]()
    var directoryUrls = [URL]()
    
    static let share = DirectoriesPresenter()
    
    func createDirectory(name : String , complation : (Bool) -> Void){
        let url =  Constants.documentsDirectoryURL.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: url.path ){
            complation(false)
        }
        else {
            do {
                let directoryURL =  Constants.documentsDirectoryURL.appendingPathComponent(name)
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true , attributes: nil)
                complation(true)
            } catch  {
                print(error)
            }
        }
    }
    
    func getDirectory() -> [URL] {
        do {
            directoryUrls = try FileManager.default.contentsOfDirectory(at:  Constants.documentsDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
        } catch {
            print(error.localizedDescription)
        }
        return directoryUrls
    }
    
    
    func deleteIteams(url : URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch  {
            print(error)
        }
    }
    
    
    func storeDirectory() {
        directoryUrls = getDirectory()
    }
    
    func checkStorage(completion : (Bool) -> Void ) {
        guard let totalfileSize =  FileManager.default.directorySize( Constants.documentsDirectoryURL) else{return}
        if totalfileSize < Constants.storageLimit{
            completion(true)
        }else{
            completion(false)
        }
    }
    
    
    func storageCalculator(usedStorage : Int) -> String{
        let gb = 1024 * 1024 * 1024
        let remaningStorage = String(format: "%.2f", Double(Constants.storageLimit - usedStorage) / Double(gb))
        return remaningStorage
    }
    
    func givesizeOfStorage() -> Int {
        return FileManager.default.directorySize( Constants.documentsDirectoryURL) ?? 0
    }
    
}
