//
//  DocumentPreseneter.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 12/05/23.
//

import Foundation


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
    
    
    
    func pasteDocuments(desurl : URL , addcomponet : String , complation : (Bool) -> Void ){
        let sourceurl =  Constants.documentsDirectoryURL.appendingPathComponent(addcomponet)
        let lastcom = sourceurl.lastPathComponent
        let finalurl = desurl.appendingPathComponent(lastcom)
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
    
        for data in DocumetsPresenter.obj.copyurls {
             let copyurl = CopyURLS(context: DatabaseHandler.database.contex)
             copyurl.copyurls = DirectoriesPresenter.share.saveURLs(url: data)
             DatabaseHandler.database.save()
        }
    }
    
    func moveOperation (selectedurl : URL , desurl : URL) {
        do {
            try  FileManager.default.moveItem(at: desurl, to: selectedurl)
            self.documentsFiles.append(desurl)
        } catch  {
            print(error.localizedDescription)
        }
    }
}

enum SelectionError : Error {
    case fileExist(message : String)
    case fileSize(message : String)
}
