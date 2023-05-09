//
//  DocumentryTableViewController.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 09/05/23.
//

import UIKit
import CoreData

class DocumentryTableViewController: UITableViewController {
    
    var folderArray = [Directory]()
    let context = PersistanceStorage.share.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.LoadDirectory()
    }
    
    // MARK: - Table view data source
    
    
    @IBAction func addFolderPress(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Create Folder", message: "Enter Folder Name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            let newDirectory = Directory(context: self.context)
            newDirectory.name = textField.text!
            self.folderArray.append(newDirectory)
            self.saveDirectory()
            
        }
        let Cancleaction = UIAlertAction(title: "Cancle", style: .default)
        alert.addAction(Cancleaction)
        alert.addAction(okAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Name of your Folder"
        }
        present(alert, animated: true, completion: nil)
        
    }
}

extension DocumentryTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DocumentryTableViewCell
        cell.nameLable?.text = folderArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            DataBaseHandler.database.delete(object: (folderArray[indexPath.row]))
            self.folderArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }

}

extension DocumentryTableViewController {
    
    func saveDirectory() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func LoadDirectory() {
        
        let request : NSFetchRequest<Directory> = Directory.fetchRequest()
        
        do{
            folderArray = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
}
