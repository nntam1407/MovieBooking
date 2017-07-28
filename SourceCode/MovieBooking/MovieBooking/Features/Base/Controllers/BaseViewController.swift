//
//  AhaBaseViewController.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 1/19/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Register other notifications
        Utils.regNotif(self, selector: #selector(BaseViewController.updateAllLocalizedText), name: kNotificationUpdateLocalizedText, object: nil)
        
        // Set all text
        self.updateAllLocalizedText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register keyboard notification
        Utils.regNotif(self, selector: #selector(BaseViewController.handleEventKeyboadWillShow(_:)),
                       name: NSNotification.Name.UIKeyboardWillShow.rawValue,
                       object: nil)
        
        Utils.regNotif(self, selector: #selector(BaseViewController.handleEventKeyboadWillHide(_:)),
                       name: NSNotification.Name.UIKeyboardWillHide.rawValue,
                       object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Should remove keyboad event
        Utils.removeNotif(self, name: NSNotification.Name.UIKeyboardWillShow.rawValue, object: nil)
        Utils.removeNotif(self, name: NSNotification.Name.UIKeyboardWillHide.rawValue, object: nil)
    }
    
    deinit {
        DLog("View controller deinit.")
        
        // Unreg all notification
        Utils.removeAllNotif(self)
    }
    
    // MARK: Handle event methods
    @objc func handleEventKeyboadWillShow(_ notification: Notification) {
        let keyboardInfo = (notification as NSNotification).userInfo as NSDictionary?
        
        if (keyboardInfo != nil) {
            let duration: Double! = keyboardInfo!.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
            let options = keyboardInfo!.object(forKey: UIKeyboardAnimationCurveUserInfoKey) as! UInt
            
            var keyboardFrame = CGRect.zero
            (keyboardInfo?.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).getValue(&keyboardFrame)
            
            // Call methods
            self.keyboardWillShow(keyboardFrame.size.height, duration: duration, animationOption: UIViewAnimationOptions(rawValue: options))
        }
    }
    
    @objc func handleEventKeyboadWillHide(_ notification: Notification) {
        let keyboardInfo = (notification as NSNotification).userInfo as NSDictionary?
        
        if (keyboardInfo != nil) {
            let duration: Double! = keyboardInfo!.object(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
            let options = keyboardInfo!.object(forKey: UIKeyboardAnimationCurveUserInfoKey) as! UInt
            
            var keyboardFrame = CGRect.zero
            (keyboardInfo?.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).getValue(&keyboardFrame)
            
            // Call methods
            self.keyboadWillHide(keyboardFrame.size.height, duration: duration, animationOption: UIViewAnimationOptions(rawValue: options))
        }
    }
    
    // MARK: Abstract methods, they should be overrided in subclass
    
    func keyboardWillShow(_ keyboardHeight: CGFloat, duration: Double, animationOption: UIViewAnimationOptions) {
        // Should overrieded in subclass
    }
    
    func keyboadWillHide(_ keyboardHeight: CGFloat, duration: Double, animationOption: UIViewAnimationOptions) {
        // Should overrieded in subclass
    }
    
    @objc func updateAllLocalizedText() {
        // We should put all text can be updated localized realtime in here. This method will support for change language in app
    }

}
