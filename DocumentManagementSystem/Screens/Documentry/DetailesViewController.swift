//
//  DetailesViewController.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 09/05/23.
//

import UIKit
import MobileCoreServices
import QuickLook
import DropDown


class DetailesTableViewController: UITableViewController{
    var desUrl : URL? = nil
    var copyurls = [URL]()
    var copy = true
    @IBOutlet weak var copyBtnPress: UIBarButtonItem!
    
    
    let menu : DropDown = {
        let menu = DropDown()
        menu.dataSource = [
          "copy",
          "Paste",
          "select"
        ]
        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = desUrl else{
            return
        }
        DocumetsPresenter.obj.subDirectorys(url: url)
        setUpMenu()
       
    }
    
    @IBAction func copybtnPress(_ sender: UIBarButtonItem) {
        menu.show()
    }
        
    @IBAction func addDocumentsPress(_ sender: UIBarButtonItem) {
         addDocumentPicker()
    }
    
}


// Mark : TableviewController
extension DetailesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  DocumetsPresenter.obj.detailes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailsTableViewCell
        generateThumnail(url:  DocumetsPresenter.obj.detailes[indexPath.row]) { image in
            DispatchQueue.main.async {
                cell.thumbnailImg.image = image
            }
        }
        cell.nameLable?.text =  DocumetsPresenter.obj.detailes[indexPath.row].lastPathComponent
        print(DocumetsPresenter.obj.detailes)
       return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            Manager.share.Delelte(url:  DocumetsPresenter.obj.detailes[indexPath.row])
            DocumetsPresenter.obj.detailes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if copy{
            let quickLookViewController = QLPreviewController()
            quickLookViewController.dataSource = self
            quickLookViewController.currentPreviewItemIndex = indexPath.row
            present(quickLookViewController, animated: true)
        }
        else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}


// Mark : QlPreviewController

extension DetailesTableViewController : QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        DocumetsPresenter.obj.detailes.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        DocumetsPresenter.obj.detailes[index] as QLPreviewItem
    }
}



// Mark :- UIDocumentsPicker
extension DetailesTableViewController : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let sizeofFile = 1024 * 1024 * 1024
        guard let selectedFileURL = urls.first else {
            return
        }
        do {
            let fileSize = try selectedFileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            print("File size: \(fileSize) bytes")
            let sandboxFileURL = desUrl!.appendingPathComponent(selectedFileURL.lastPathComponent)
            if fileSize < sizeofFile{
                if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
                    print("Already exists! Do nothing")
                }
                else {
                    do {
                        try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL )
                    }
                    catch {
                        print("Error: \(error)")
                    }
                }
                DocumetsPresenter.obj.detailes.append(sandboxFileURL)
                tableView.reloadData()
            }
            else{
                alert(title: "File size limit Exceedded", message: "Please select file(s) smaller than 1 GB.", okActionTitle: "OK")
            }
        }
        catch {
            print("Error getting file size: \(error.localizedDescription)")
        }

    }
    
}

extension DetailesTableViewController {
    
    func generateThumnail(url : URL , comletion : @escaping (UIImage) -> Void) {
        let size = CGSize(width: 50, height: 50)
           let scale = UIScreen.main.scale
        let request = QLThumbnailGenerator.Request(
              fileAt: url,
              size: size,
              scale: scale,
              representationTypes: .all)
        
        
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
          if let thumImage = thumbnail {
              comletion(thumImage.uiImage)
          }else{
              print(error!)
           }
        }
    }
    
    func addDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePlainText as String , kUTTypePDF as String , kUTTypePNG as String , kUTTypeMPEG4 as String , kUTTypeJPEG as String], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
}


extension DetailesTableViewController {
    func setUpMenu(){
        menu.selectionAction = { (index , iteam) in
            if index == 0 {
                print(index)
                self.copyurls.removeAll()
                if let selected  = self.tableView.indexPathsForSelectedRows{
                    for indexpath in  selected {
                        self.copyurls.append( DocumetsPresenter.obj.detailes[indexpath.row])
                    }
                }
                let defaults = UserDefaults.standard
                defaults.set(self.copyurls[0], forKey: "copyURL")
                
            }
            else if index == 1 {
                do {
                    let value = UserDefaults.standard.string(forKey: "copyURL")
                    if let url = URL(string: value!) {
                        print(url)
                        try FileManager.default.copyItem(at: url, to: self.desUrl!)
                    }
                } catch {
                    print(error)
                }
                DocumetsPresenter.obj.detailes.append(contentsOf: self.copyurls)
                self.tableView.reloadData()
            }
            
            else if index == 2 {
                self.copy = false
                self.tableView.allowsMultipleSelectionDuringEditing = true
                self.tableView.setEditing(true, animated: false)
            }
        }
    }
}
