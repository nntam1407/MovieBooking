//
//  SettingTableViewController.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit
import MessageUI

class SettingTableViewController: BaseTableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var appVersionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = NSLocalizedString("More", comment: "")
        
        // App version
        self.appVersionLabel.text = "Version: " + Utils.fullAppVersion()
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                let appStoreURL = URL(string: kAppStoreURL)
                UIApplication.shared.openURL(appStoreURL!)
                
            } else if indexPath.row == 1 {
                // Share with friends
                let ituneURL = URL(string: kAppStoreURL)
                let activityVC = UIActivityViewController(activityItems: [ituneURL!], applicationActivities: nil)
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let cell = tableView.cellForRow(at: indexPath)
                    
                    let popOver = UIPopoverController(contentViewController: activityVC)
                    popOver.present(from: CGRect(x: cell!.frame.size.width / 2.0, y: cell!.frame.height / 2.0, width: 0, height: 0), in: tableView, permittedArrowDirections: .any, animated: true)
                } else {
                    self.present(activityVC, animated: true, completion: nil)
                }
                
            } else if (indexPath.row == 2) {
                // Send feedback
                if MFMailComposeViewController.canSendMail() {
                    // Open mail comporse
                    let mailVC = MFMailComposeViewController()
                    mailVC.setToRecipients([kAppSupportEmail])
                    mailVC.setSubject(String(format: NSLocalizedString("%@ App Feedback", comment: ""), kAppName))
                    mailVC.mailComposeDelegate = self
                    
                    self.present(mailVC, animated: true, completion: nil)
                } else {
                    AlertUtils.showAlert(title: NSLocalizedString("Could Not Send Email", comment: ""), message: NSLocalizedString("Your device could not send e-mail.\nPlease check e-mail configuration and try again.", comment: ""), okButtonTitle: NSLocalizedString("OK", comment: ""), onViewController: self)
                }
            }
        }
    }
    
    // MARK:
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if error != nil {
            AlertUtils.showAlert(title: NSLocalizedString("Could Not Send Email", comment: ""), message: error?.localizedDescription, okButtonTitle: NSLocalizedString("OK", comment: ""), onViewController: controller, completed: {
                controller.dismiss(animated: true, completion: nil)
            })
            
            return
        } else {
            if result == .sent {
                AlertUtils.showAlert(title: NSLocalizedString("Sent Email Successful", comment: ""), message: String(format: NSLocalizedString("Thanks for your feedback. We will make %@ be better.", comment: ""), kAppName), okButtonTitle:NSLocalizedString("OK", comment: ""), onViewController: controller, completed: {
                    controller.dismiss(animated: true, completion: nil)
                })
                
                return
            }
        }
        
        // Just dismiss this compose
        controller.dismiss(animated: true, completion: nil)
    }
}
