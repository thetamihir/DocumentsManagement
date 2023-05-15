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
        let url =  documentsDirectoryURL.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: url.path ){
            complation(false)
        }
        else {
            do {
                let directoryURL = documentsDirectoryURL.appendingPathComponent(name)
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true , attributes: nil)
                complation(true)
            } catch  {
                print(error)
            }
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
    
    func pasteDocuments(desurl : URL , addcomponet : String){
        
        let sourceurl = documentsDirectoryURL.appendingPathComponent(addcomponet)
        let lastcom = sourceurl.lastPathComponent
        let finalurl = desurl.appendingPathComponent(lastcom)
        do {
            try FileManager.default.copyItem(at: sourceurl, to: finalurl)
            DocumetsPresenter.obj.documentsFiles.append(finalurl)
        } catch  {
            print(error)
        }
    }
    
    
    func saveURLs(url : URL) -> String {
        var stringurl : String? = nil
        let pathComponents = url.pathComponents
        if pathComponents.count >= 2 {
            let secondLastComponent = pathComponents[pathComponents.count - 2]
            let lastComponent = url.lastPathComponent
            stringurl = "\(secondLastComponent)/\(lastComponent)"
            
        }
        return stringurl ?? ""
    }
    
}
