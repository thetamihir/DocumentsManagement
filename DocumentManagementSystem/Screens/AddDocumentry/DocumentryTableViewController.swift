//
//  DocumentryTableViewController.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 09/05/23.
//

import UIKit

class DocumentryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Directories"
        Manager.share.storeDirectory()
        biomericAuth()
    }
    
    @IBAction func addFolderPress(_ sender: UIBarButtonItem) {
        addDirectory()
    }
}


// Mark : TableView Delegates and DataSource
extension DocumentryTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Manager.share.directoryUrls.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DocumentryTableViewCell
        cell.nameLable?.text = Manager.share.directoryUrls[indexPath.row].lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Manager.share.Delelte(url: Manager.share.directoryUrls[indexPath.row])
            Manager.share.directoryUrls.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "detailsVC") as! DetailesTableViewController
        vc.desUrl = Manager.share.directoryUrls[indexPath.row]
        vc.title = Manager.share.directoryUrls[indexPath.row].lastPathComponent
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



// Extra Functions
extension DocumentryTableViewController {
    func biomericAuth() {
        BiometricAuth.share.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                alert(title: "Error",
                      message: canEvaluateError?.localizedDescription ?? "Face ID/Touch ID may not be configured",
                      okActionTitle: "Try Again!")
                return
            }
            
            BiometricAuth.share.evaluate { [weak self] (success, error) in
                guard success else {
                    self?.alert(title: "Error",
                                message: error?.localizedDescription ?? "Face ID/Touch ID may not be configured",
                                okActionTitle: "Try Again!")
                    self?.biomericAuth()
                    return
                }
                
                self?.alert(title: "Success",
                            message: "You have a free pass, now",
                            okActionTitle: "Success!")
            }
        }
    }
    
    
    func addDirectory(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Create Folder", message: "Enter Folder Name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            Manager.share.createDirectory(name: textField.text ?? "newfolder") { succsse in
                guard succsse else {return}
            }
            Manager.share.directoryUrls = Manager.share.getDirectory()
            self.tableView.reloadData()
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
    
extension UIViewController {
    func alert(title: String, message: String, okActionTitle: String) {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default)
        alertView.addAction(okAction)
        self.present(alertView, animated: true)
    }
}
