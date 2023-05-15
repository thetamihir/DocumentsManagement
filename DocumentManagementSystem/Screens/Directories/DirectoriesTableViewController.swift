//
//  DocumentryTableViewController.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 09/05/23.
//

import UIKit

class DirectoriesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Directories"
        Manager.share.storeDirectory()
       // biomericAuth()
        setupLable()
       
    }
    
    @IBAction func addFolderPress(_ sender: UIBarButtonItem) {
        addDirectory()
    }
}


// Mark : TableView Delegates and DataSource
extension DirectoriesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Manager.share.directoryUrls.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DirectoriesTableViewCell
        cell.nameLable?.text = Manager.share.directoryUrls[indexPath.row].lastPathComponent
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Manager.share.deleteIteams(url: Manager.share.directoryUrls[indexPath.row])
            Manager.share.directoryUrls.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)

        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "detailsVC") as! DocumentsTableViewController
        vc.desUrl = Manager.share.directoryUrls[indexPath.row]
        vc.title = Manager.share.directoryUrls[indexPath.row].lastPathComponent
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



// Extra Functions
extension DirectoriesTableViewController {
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
                    self?.reAuthalert(title: "Error", message: error?.localizedDescription ?? "Face ID/Touch ID may not be configured" , okActionTitle: "Try Again!")
                    return
                }
            }
        }
    }
    
    func addDirectory(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Create Folder", message: "Enter Folder Name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            Manager.share.createDirectory(name: textField.text ?? "newfolder") { succsse in
                guard succsse else {return
                    self.alert(title: "File already exist!", message: "please try using uniqe name ", okActionTitle: "Try again!")
                }
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
    
    
    func reAuthalert(title: String, message: String, okActionTitle: String) {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert )
        let okAction = UIAlertAction(title: okActionTitle, style: .default) { action in
            self.biomericAuth()
        }
        alertView.addAction(okAction)
        self.present(alertView, animated: true)
    }
    
    func setupLable(){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
          label.center = tableView.center
          label.textAlignment = .center
          label.numberOfLines = 0
          label.text = "Please Add Directroy using above + click"
        if Manager.share.directoryUrls.count == 0{
            self.view.addSubview(label)
        
        }
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
