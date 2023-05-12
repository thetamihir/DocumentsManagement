//
//  DocumentPreseneter.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 12/05/23.
//

import Foundation

import Foundation

class DocumetsPresenter{
    let sizeofFile = 1024 * 1024 * 1024
    static let obj = DocumetsPresenter()
    var detailes = [URL]()
    
    
    func subDirectorys(url : URL){
        do {
            DocumetsPresenter.obj.detailes =  try  FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey, .fileSizeKey ] , options: .skipsHiddenFiles)
        } catch  {
            print(error)
        }
    }
    
//
//    func checkLimit(size : Int , sourceURL : URL , destinationURL : URL , completion : (Bool) -> Void ){
//        if size < sizeofFile{
//            if FileManager.default.fileExists(atPath: destinationURL.path) {
//                print("Already exists! Do nothing")
//            }
//            else {
//                do {
//                    try FileManager.default.copyItem(at: sourceURL, to: destinationURL )
//                }
//                catch {
//                    print("Error: \(error)")
//                }
//            }
//        }
//
//    }
    
}
