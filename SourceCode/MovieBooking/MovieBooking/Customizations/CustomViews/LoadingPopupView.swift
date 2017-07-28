//
//  LoadingPopupView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 11/23/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

class LoadingPopupView: NSObject {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // Properties
    
    var mainView: UIView?
    var loadingIndicatorView: MaterialIndicatorView?
    
    // MARK: Class methods
    
    static let sharedInstance : LoadingPopupView = {
        let instance = LoadingPopupView()
        
        return instance
    }()
    
    class func showLoading() {
        LoadingPopupView.sharedInstance.showLoading()
    }

    class func hideLoading() {
        LoadingPopupView.sharedInstance.hideLoading()
    }
    
    // MARK: Override methods
    
    override init() {
        super.init()
        
        // Create base UI
        self.createBaseUI()
    }
    
    // MARK: Private methods
    
    private func createBaseUI() {
        if (self.mainView == nil) {
            self.mainView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            self.mainView!.backgroundColor = UIColor.white
            self.mainView!.layer.cornerRadius = 4.0
            self.mainView!.alpha = 0
        }
        
        if (self.loadingIndicatorView == nil) {
            self.loadingIndicatorView = MaterialIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            self.loadingIndicatorView!.hideWhenStop = true
            self.loadingIndicatorView!.startAnimating()
            
            // Add on main view
            self.mainView!.addSubview(self.loadingIndicatorView!)
            self.loadingIndicatorView!.center = CGPoint(x: self.mainView!.frame.size.width/2, y: self.mainView!.frame.size.height/2)
        }
    }
    
    // MARK: Public methods
    
    func showLoading() {
        self.mainView!.showAsPopup(1.0, overlayOpacity: 0.5)
    }
    
    func hideLoading() {
        self.mainView!.hidePopup(true)
    }
}
