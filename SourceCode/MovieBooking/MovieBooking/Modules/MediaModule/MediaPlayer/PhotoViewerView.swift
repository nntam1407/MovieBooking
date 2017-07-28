//
//  PhotoViewerView.swift
//  ChatApp
//
//  Created by Tam Nguyen Ngoc on 2/28/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

class PhotoViewerView: UIView {

    @IBOutlet weak var imageScrollView: ImageScrollView!
    @IBOutlet weak var circleLoadingView: CircleLoadingView!
    @IBOutlet weak var doneButton: UIButton!
    
    private var topWindow: UIWindow?
    
    /// Create temp image view to download image
    private var tempImageView: UIImageView?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    class func createPhotoViewer() -> PhotoViewerView {
        return Utils.loadView("PhotoViewerView") as! PhotoViewerView
    }
    
    // MARK: Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.circleLoadingView.color = UIColor.white
        self.circleLoadingView.strokeWidthPercent = 0.05
        
        self.doneButton.layer.cornerRadius = 3.0
        self.doneButton.layer.borderWidth = 1.0
        self.doneButton.layer.borderColor = UIColor.white.cgColor
        self.doneButton.backgroundColor = UIColor(white: 0, alpha: 0.3)
    }

    // MARK: Handle events
    
    @IBAction func didTouchDoneButton(_ sender: AnyObject) {
        // Should stop downloading image if have
        self.tempImageView?.stopDownloadingImage()
        
        // Dismiss view
        self.dismissImageViewer(true)
    }
    
    // MARK: Support methods
    
    func displayImage(_ image: UIImage) {
        // Should stop downloading image if have
        self.tempImageView?.stopDownloadingImage()
        
        self.imageScrollView.displayImage(image, fadeEffect: true)
    }
    
    func displayImageURL(_ url: String) {
        weak var weakSelf = self
        
        self.circleLoadingView.isHidden = false
        self.circleLoadingView.value = 0.05
        
        // Create temp image view, then download image from URL
        if self.tempImageView == nil {
            self.tempImageView = UIImageView(frame: CGRect.zero)
        }
        
        self.tempImageView!.setImageURL(url,
            hightlightImageURL: nil,
            defaultImage: nil,
            progressBlock: { (url, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) -> Void in
                if (weakSelf != nil) {
                    weakSelf!.circleLoadingView.isHidden = false
                    weakSelf!.circleLoadingView.value = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
                }
            }) { (image) -> Void in
                // Display image after download
                if (weakSelf != nil) {
                    weakSelf!.circleLoadingView.isHidden = true
                    weakSelf!.tempImageView?.image = nil
                    
                    if (image != nil) {
                        weakSelf!.displayImage(image!)
                    }
                }
        }
    }
    
    func presentImageViewer(_ animated: Bool) {
        // Do nothing if this video currently added
        if (self.superview != nil) {
            return
        }
        
        // Create new top window
        self.topWindow = UIWindow(frame: UIScreen.main.bounds)
        self.topWindow!.makeKeyAndVisible()
        
        // Move this windows on top of status bar
        self.topWindow!.windowLevel = UIWindowLevelStatusBar + 1
        
        self.frame = CGRect(x: 0, y: 0, width: self.topWindow!.frame.size.width, height: self.topWindow!.frame.size.height)
        self.topWindow!.addSubview(self)
        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        if (animated) {
            self.alpha = 0
            
            UIView.animate(withDuration: 0.45, delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.alpha = 1.0
                }, completion: { (finished) -> Void in
                    self.alpha = 1.0
            })
        } else {
            self.alpha = 1.0
        }
    }
    
    func dismissImageViewer(_ animated: Bool) {
        if (self.superview == nil) {
            return
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.45, delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.alpha = 0
                }, completion: { (finished) -> Void in
                    self.removeFromSuperview()
                    self.topWindow = nil
            })
        } else {
            self.removeFromSuperview()
            self.topWindow = nil
        }
    }
}
