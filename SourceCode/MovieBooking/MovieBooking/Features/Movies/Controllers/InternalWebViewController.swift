//
//  InternalWebViewController.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/30/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

class InternalWebViewController: BaseViewController, UIWebViewDelegate {
    
    @IBOutlet weak var mainWebView: UIWebView!
    @IBOutlet weak var centerIndicatorView: MaterialIndicatorView!
    
    @IBOutlet weak var bottomActionView: UIView!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    @IBOutlet weak var bottomIndicatorView: MaterialIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var url: URL?
    var isFirstTimeLoading = false
    var hideDoneButton = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.title == nil {
            self.title = self.url?.absoluteString
        }
        
        if self.url != nil {
            self.isFirstTimeLoading = true
            self.mainWebView.loadRequest(URLRequest(url: self.url!))
        }
        
        // Display close button
        if !self.hideDoneButton {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InternalWebViewController.didTouchOnDoneButton(sender:)))
            self.navigationItem.leftBarButtonItems = [doneButton]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK:
    // MARK: UI's events
    
    func didTouchOnDoneButton(sender: Any) {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else if self.navigationController != nil && self.navigationController!.viewControllers.count >= 2 {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func didTouchOnBackButton(_ sender: Any) {
        self.mainWebView.goBack()
    }
    
    @IBAction func didTouchOnForwardButton(_ sender: Any) {
        self.mainWebView.goForward()
    }
    
    @IBAction func didTouchOnRefreshButton(_ sender: Any) {
        self.mainWebView.reload()
    }
    
    // MARK:
    // MARK: UIWebViewDelegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        if self.isFirstTimeLoading {
            self.centerIndicatorView.startAnimating()
        } else {
            self.bottomIndicatorView.startAnimating()
        }
        
        self.refreshButton.isHidden = true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.centerIndicatorView.stopAnimating()
        self.bottomIndicatorView.stopAnimating()
        
        if (error as NSError).code != NSURLErrorCancelled {
            AlertUtils.showAlert(title: error.localizedDescription, message: nil, okButtonTitle: NSLocalizedString("OK", comment: ""), onViewController: self)
        }
        
        self.refreshButton.isHidden = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.isFirstTimeLoading = false
        self.centerIndicatorView.stopAnimating()
        self.bottomIndicatorView.stopAnimating()
        
        self.goBackButton.isEnabled = self.mainWebView.canGoBack
        self.goForwardButton.isEnabled = self.mainWebView.canGoForward
        
        self.refreshButton.isHidden = false
    }

}
