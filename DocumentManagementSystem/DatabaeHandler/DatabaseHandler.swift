//
//  databaseHandler.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 15/05/23.
//

import Foundation
import CoreData


class DatabaseHandler {
    static let database = DatabaseHandler()
    let contex = PersistanceStorage.share.persistentContainer.viewContext
    

    func fetch <T : NSManagedObject> (_ type : T.Type) -> [T] {
        let request = T.fetchRequest()
        do {
          let result  =  try contex.fetch(request)
            return result as! [T]
        } catch  {
            print(error.localizedDescription)
            return []
        }
    }
    
    func save(){
        do {
            try contex.save()
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func delete<T : NSManagedObject> (object : T) {
        contex.delete(object)
        save()
    }
    
  
//    func fetchCopyurls() -> [CopyURLS]{
//        var urls = [CopyURLS]()
//        let request : NSFetchRequest<CopyURLS> = CopyURLS.fetchRequest()
//        do{
//            urls = try contex.fetch(request)
//        } catch {
//            print("Error loading categories \(error)")
//        }
//        return urls
//    }
//
//
//    func deleteCoredata() {
//        let data  = fetch(CopyURLS.self)
//        for data in data {
//            delete(object: data)
//        }
//    }

}
