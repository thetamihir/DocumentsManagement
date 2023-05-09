//
//  ViewController.swift
//  DocumentManagementSystem
//
//  Created by Mihir Shingala on 09/05/23.
//

import UIKit
import LocalAuthentication
import MobileCoreServices


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let manager = FileManager.default
        guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first  else {return}
        print(url.path)
    

        let newfolder = url.appendingPathComponent("mihir")
        do {
            try manager.createDirectory(at: newfolder, withIntermediateDirectories: true)
        } catch  {
            print(error)
        }
    }
    
}
















extension ViewController {
    
    func Auth() {
        BiometricAuth.share.canEvaluate { success, error in
            
            guard success else {
                alert(title: "Error",
                      message: error?.localizedDescription ?? "Face ID/Touch ID may not be configured",
                      okActionTitle: "OK!")
                return
            }
            BiometricAuth.share.evaluate { sucess, error in
                guard success else {
                    self.alert(title: "Authetication",
                                message: error?.localizedDescription ?? "Face ID/Touch ID may not be configured",
                                okActionTitle: "OK!")
                    return
                }
                self.alert(title: "Success",
                            message: "You have a free pass, now",
                            okActionTitle: "Success")
            }
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
