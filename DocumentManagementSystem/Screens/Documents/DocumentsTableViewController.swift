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


class DocumentsTableViewController: UITableViewController, UIGestureRecognizerDelegate{
    var desUrl : URL? = nil
    var copy = true
    var selected = false
    @IBOutlet weak var copyBtnPress: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(DocumentsTableViewController.tapEdit(recognizer:)))
        tableView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = desUrl else{
            return
        }
        DocumetsPresenter.obj.subDirectorys(url: url)
    }
    
    @IBAction func copybtnPress(_ sender: UIBarButtonItem) {
        addActionsheet()
    }
        
    @IBAction func addDocumentsPress(_ sender: UIBarButtonItem) {
        DirectoriesPresenter.share.checkStorage { success in
            guard success else {return
                self.alert(title: "storage limit!", message: "please delete some big files", okActionTitle: "cancle")
            }
            addDocumentPicker()
        }
    }
    
    
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.began {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if self.tableView.cellForRow(at: tapIndexPath) is DocumentsTableViewCell {
                    print("long press")
                    self.copy = false
                    self.selected = true
                    self.tableView.allowsMultipleSelectionDuringEditing = true
                    self.tableView.setEditing(true, animated: false)

                }
            }
        }
    }
    
}


// Mark : TableviewController
extension DocumentsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  DocumetsPresenter.obj.documentsFiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DocumentsTableViewCell
        generateThumnail(url:  DocumetsPresenter.obj.documentsFiles[indexPath.row]) { image in
            DispatchQueue.main.async {
                cell.thumbnailImg.image = image
            }
        }
        cell.nameLable?.text =  DocumetsPresenter.obj.documentsFiles[indexPath.row].lastPathComponent
       return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            DirectoriesPresenter.share.deleteIteams(url:  DocumetsPresenter.obj.documentsFiles[indexPath.row])
            DocumetsPresenter.obj.documentsFiles.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
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

extension DocumentsTableViewController : QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        DocumetsPresenter.obj.documentsFiles.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        DocumetsPresenter.obj.documentsFiles[index] as QLPreviewItem
    }
}



// Mark :- UIDocumentsPicker
extension DocumentsTableViewController : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        do {
            let fileSize = try selectedFileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            print("File size: \(fileSize) bytes")
            guard let storagesize =  FileManager.default.directorySize( Constants.documentsDirectoryURL) else {return}
            
            DocumetsPresenter.obj.checkStorage(selectedFile: fileSize, storagesize: storagesize) { success in
                guard success else { return
                    alert(title: "Storage Limits", message: "your storage is almostfull!", okActionTitle: "OK")
                }
                DocumetsPresenter.obj.checkLimit(selectedURL: selectedFileURL, destinationURL: desUrl!, fileSize: fileSize) { response in
                    switch response {
                    case .success :
                        tableView.reloadData()
                    case .failure(let error) :
                        print(error)
                        alert(title: "Alert", message: "file is already exist" , okActionTitle: "OK")
                    }
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        
    }
    
}

extension DocumentsTableViewController {
    
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


extension DocumentsTableViewController {

    func addActionsheet(){
        let alertController = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        
        let copyButton = UIAlertAction(title: "Copy", style: .default) { action in
            print("copy")
            if self.selected{
                DocumetsPresenter.obj.copyurls.removeAll()
                DatabaseHandler.database.deleteCoredata()
                if let selectedurls  = self.tableView.indexPathsForSelectedRows{
                    DocumetsPresenter.obj.copyOperation(indexPath: selectedurls)
                }
                self.tableView.setEditing(false, animated: false)
            }
            else {
                self.alert(title: "Please Selecte Files", message: "Nothing  Selected", okActionTitle: "Try Again!")
            }
            
        }
        
        let pasteButton = UIAlertAction(title: "Paste", style: .default) { action in
            print("paste")
            
            DirectoriesPresenter.share.checkStorage { success in
                guard success else {return
                    self.alert(title: "storage limit!", message: "please delete some big files", okActionTitle: "cancle")
                }
                let geturlPath = DatabaseHandler.database.fetch(CopyURLS.self)
                for path in geturlPath {
                    DocumetsPresenter.obj.pasteDocuments(desurl: self.desUrl!, addcomponet: path.copyurls!){success in
                        guard success else {return
                            self.alert(title: "Alert", message: "Some files are alredy exist", okActionTitle: "OK")
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
        }
        
        let selectButton = UIAlertAction(title: "Select", style: .default) { action in
            print("select")
            self.copy = false
            self.selected = true
            self.tableView.allowsMultipleSelectionDuringEditing = true
            self.tableView.setEditing(true, animated: false)
        }
        
//        let moveButton = UIAlertAction(title: "Move", style: .default){
//            action in
//            if let selectedurl  = self.tableView.indexPathsForSelectedRows{
//                self.moveurl = DocumetsPresenter.obj.documentsFiles[selectedurl[0].row]
//            }
//            self.addDocumentPicker()
//        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("cancel")
        }
        
        alertController.addAction(copyButton)
        alertController.addAction(pasteButton)
        alertController.addAction(selectButton)
        alertController.addAction(cancelButton)
       // alertController.addAction(moveButton)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}
