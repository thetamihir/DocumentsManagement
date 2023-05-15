//
//  DocumentPreseneter.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 12/05/23.
//

import Foundation


class DocumetsPresenter{
   
    static let obj = DocumetsPresenter()
    let sizeofFile = 1024 * 1024 * 1024
    var documentsFiles = [URL]()
    var copyurls = [URL]()
    
    
    func subDirectorys(url : URL){
        do {
            DocumetsPresenter.obj.documentsFiles =  try  FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey, .fileSizeKey ] , options: .skipsHiddenFiles)
        } catch  {
            print(error)
        }
    }
    
    func checkLimit(selectedURL : URL, destinationURL : URL , fileSize : Int , completion : (Bool) -> Void) {
        let finalURl = destinationURL.appendingPathComponent(selectedURL.lastPathComponent)
        if (fileSize < sizeofFile) {
            if FileManager.default.fileExists(atPath: finalURl.path) {
                print("Already exists! Do nothing")
            }
            else {
                do {
                    try FileManager.default.copyItem(at: selectedURL, to: finalURl)
                    self.documentsFiles.append(finalURl)
                    completion(true)
                }
                catch {
                    print("Error: \(error)")
                }
            }
        }
        else{
            completion(false)
        }
    }
    

    func copyOperation(indexPath : [IndexPath]){
        
        for indexpath in indexPath {
            copyurls.append(documentsFiles[indexpath.row])
        }
    
        for data in DocumetsPresenter.obj.copyurls {
             let copyurl = CopyURLS(context: DatabaseHandler.database.contex)
             copyurl.copyurls = Manager.share.saveURLs(url: data)
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
