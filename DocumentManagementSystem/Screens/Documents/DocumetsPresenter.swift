//
//  DocumentPreseneter.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 12/05/23.
//

import Foundation
import CoreData

class DocumetsPresenter{
   
    static let obj = DocumetsPresenter()
    var documentsFiles = [URL]()
    var copyurls = [URL]()
   
    
    func subDirectorys(url : URL){
        do {
            DocumetsPresenter.obj.documentsFiles =  try  FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey, .fileSizeKey ] , options: .skipsHiddenFiles)
        } catch  {
            print(error)
        }
    }
    
    
    func checkStorage(selectedFile : Int , storagesize : Int , completion : (Bool) -> Void){
        if ((selectedFile + storagesize) < Constants.storageLimit){
            completion(true)
        }else{
            completion(false)
        }
    }
    
    func checkLimit(selectedURL : URL, destinationURL : URL , fileSize : Int , completion : (Result<Bool , SelectionError>) -> Void) {
        let finalURl = destinationURL.appendingPathComponent(selectedURL.lastPathComponent)
        if (fileSize < Constants.storageLimit ) {
            if FileManager.default.fileExists(atPath: finalURl.path) {
                //print("Already exists! Do nothing")
                completion(.failure(.fileExist(message: "file is alredy exist")))
            }
            else {
                do {
                    try FileManager.default.copyItem(at: selectedURL, to: finalURl)
                    self.documentsFiles.append(finalURl)
                    completion(.success(true))
                }
                catch {
                    print("Error: \(error)")
                }
            }
        }
        else{
            completion(.failure(.fileSize(message: "file size is large")))
        }
    }
    
    
    
    func pasteDocuments(desurl : URL , addcomponent : String , complation : (Bool) -> Void ){
        let sourceurl =  Constants.documentsDirectoryURL.appendingPathComponent(addcomponent)
        let lastcomponent = sourceurl.lastPathComponent
        let finalurl = desurl.appendingPathComponent(lastcomponent)
        do {
            if FileManager.default.fileExists(atPath: finalurl.path){
                complation(false)
            }else{
                try FileManager.default.copyItem(at: sourceurl, to: finalurl)
                DocumetsPresenter.obj.documentsFiles.append(finalurl)
                complation(true)
            }
        } catch  {
            print(error)
        }
    }
    
 
    
    func copyOperation(indexPath : [IndexPath]){
        for indexpath in indexPath {
            copyurls.append(documentsFiles[indexpath.row])
        }
    
        for url in self.copyurls {
             let copyurl = CopyURLS(context: DatabaseHandler.database.contex)
             copyurl.copyurls = self.saveURLs(url: url)
             copyurl.urlsize = Int16(self.sizeOfURLs(url: url)) 
             DatabaseHandler.database.save()
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
    
    func sizeOfURLs(url : URL) -> Int {
        var size : Int? = 0
        size = url.fileSize
        return size ?? 0
    }
    
    
    func moveOperation (selectedurl : URL , desurl : URL) {
        do {
            try  FileManager.default.moveItem(at: desurl, to: selectedurl)
            self.documentsFiles.append(desurl)
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func checkStoragewhilePast(urls : [CopyURLS] , completion : (Bool) -> Void){
     let copyStorage = copyurlStorage(urls: urls)
        let totalStorage = DirectoriesPresenter.share.givesizeOfStorage()
        if (copyStorage < totalStorage){
            completion(true)
        }
        else{
            completion(false)
        }
        
    }
    
    
    func copyurlStorage(urls : [CopyURLS]) -> Int{
        var totalSize : Int = 0
        for url in urls{
            totalSize += Int(url.urlsize)
        }
        return totalSize / 1024 * 1024 * 1024
    }
    
    // Mark :- database functions
        
    func deleteCopyURLS() {
        let data  = DatabaseHandler.database.fetch(CopyURLS.self)
        for data in data {
            DatabaseHandler.database.delete(object: data)
        }
    }
}

enum SelectionError : Error {
    case fileExist(message : String)
    case fileSize(message : String)
}
