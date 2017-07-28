//
//  BaseTableViewController.swift
//  Trackhako
//
//  Created by Tam Nguyen on 7/21/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Register other notifications
        Utils.regNotif(self, selector: #selector(BaseViewController.updateAllLocalizedText), name: kNotificationUpdateLocalizedText, object: nil)
        
        // Set all text
        self.updateAllLocalizedText()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return super.numberOfSections(in: tableView)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register keyboard notification
        Utils.regNotif(self, selector: #selector(BaseViewController.handleEventKeyboadWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow.rawValue, object: nil)
        Utils.regNotif(self, selector: #selector(BaseViewController.handleEventKeyboadWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide.rawValue, object: nil)
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
