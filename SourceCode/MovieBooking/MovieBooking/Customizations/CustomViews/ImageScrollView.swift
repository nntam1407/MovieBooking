//
//  ImageScrollView.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 2/6/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

let kImageScrollViewDefaultMaxZoom: CGFloat = 2.0

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    private var imageView: UIImageView?

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateNormal
        self.delegate = self
        self.maximumZoomScale = kImageScrollViewDefaultMaxZoom
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bouncesZoom = true
        self.decelerationRate = UIScrollViewDecelerationRateNormal
        self.delegate = self
        self.maximumZoomScale = kImageScrollViewDefaultMaxZoom
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Center image view
        if (self.imageView != nil) {
            let boundSize = self.bounds.size
            var frameToCenter = self.imageView!.frame
            
            // Center horizoltally
            if (frameToCenter.size.width < boundSize.width) {
                frameToCenter.origin.x = (boundSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }
            
            // Center vertically
            if (frameToCenter.size.height < boundSize.height) {
                frameToCenter.origin.y = (boundSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }
            
            // Set frame for image view
            self.imageView!.frame = frameToCenter
            self.imageView!.contentScaleFactor = 1.0
            
            if (self.imageView!.image != nil) {
                let isMinimumZoom = self.zoomScale == self.minimumZoomScale;
                
                self.minimumZoomScale = self.minScaleForImageSize(self.imageView!.image!.size)
                self.zoomScale = isMinimumZoom ? self.minimumZoomScale : self.zoomScale
            }
        }
    }
    
    deinit {
        self.imageView?.image = nil
        self.imageView = nil
    }
    
    // MARK: UIScrollView's delegates
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    // MARK: Support methods
    
    private func minScaleForImageSize(_ imageSize: CGSize) -> CGFloat {
        let boundSize = self.bounds.size
        
        // Calculate min scale value
        let xScale = boundSize.width / imageSize.width
        let yScale = boundSize.height / imageSize.height
        
        return min(xScale, yScale)
    }
    
    func displayImage(_ image: UIImage) {
        self.displayImage(image, fadeEffect: false)
    }
    
    func displayImage(_ image: UIImage, fadeEffect: Bool) {
        // Remove previous image if have
        if (self.imageView != nil) {
            self.imageView!.removeFromSuperview()
            self.imageView = nil
        }
        
        // Set zoome scale default is 1
        self.zoomScale = 1.0
        
        // Init image
        self.imageView = UIImageView(image: image)
        self.addSubview(self.imageView!)
        
        self.contentSize = image.size
        self.minimumZoomScale = self.minScaleForImageSize(image.size)
        
        // Set current scale is minium
        self.zoomScale = self.minimumZoomScale
        
        if (fadeEffect) {
            self.imageView!.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.imageView!.alpha = 1
            })
        }
    }

}
