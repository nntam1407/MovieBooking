//
//  AlertUtils.swift
//  Trackhako
//
//  Created by Tam Nguyen on 7/21/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

class AlertUtils: NSObject {
    class func showAlert(title: String?, message: String?, okButtonTitle: String, onViewController: UIViewController) {
        AlertUtils.showAlert(title: title, message: message, okButtonTitle: okButtonTitle, onViewController: onViewController, completed: nil)
    }
    
    class func showAlert(title: String?, message: String?, okButtonTitle: String, onViewController: UIViewController, completed:(() -> Void)?) {
        if title == nil && message == nil {
            return
        }
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: { (action) in
            completed?()
        }))
        
        onViewController.present(alertVC, animated: true, completion: nil)
    }
}
