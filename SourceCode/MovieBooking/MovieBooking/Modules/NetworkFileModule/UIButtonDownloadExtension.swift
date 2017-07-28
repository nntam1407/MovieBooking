//
//  UIButtonDownloadExtension.swift
//  AskApp
//
//  Created by Tam Nguyen on 8/7/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

extension UIButton {
    
    // MARK: Download image methods
    
    /**
        Method remove all blocks handle for all states
    */
    func removeAllDownloadBlocks() {
        NetworkServices.sharedInstance.removeDownloadBlocks(nil, blocksIdentifer: self.memoryAddressString() + "_\(UIControlState())")
        
        NetworkServices.sharedInstance.removeDownloadBlocks(nil, blocksIdentifer: self.memoryAddressString() + "_\(UIControlState.highlighted)")
        
        NetworkServices.sharedInstance.removeDownloadBlocks(nil, blocksIdentifer: self.memoryAddressString() + "_\(UIControlState.selected)")
        
        NetworkServices.sharedInstance.removeDownloadBlocks(nil, blocksIdentifer: self.memoryAddressString() + "_\(UIControlState.disabled)")
    }
    
    func setImage(_ imageURL: String,
        defaultImage: UIImage?,
        forState state: UIControlState,
        progressBlock: downloadProgressBlock?,
        completed completedBlock: ((_ image: UIImage?) -> Void)?) {
            
        // First should set default image for state
        self.setImage(defaultImage, for: state)
        
        // Remove all blocks handle for this button before. This identifier base on state of button
        let blockIdentifier = self.memoryAddressString() + "_\(state)"
        NetworkServices.sharedInstance.removeDownloadBlocks(nil, blocksIdentifer: blockIdentifier)
        
        /**
            Now try to download image from imageURL
            We should check cache image first, if cache is exist, we won't download
            Cache key will be image file name generate from imageURL
        */
        let cacheKey = NetworkServices.generateDownloadFileName(imageURL)
        let cacheImage = MemCacheManager.sharedInstance.getCacheImage(cacheKey)
        
        if (cacheImage != nil) {
            self.setImage(cacheImage, for: state)
            
            completedBlock?(cacheImage)
            
        } else {
            
            // Create weak self to use in blocks
            weak var weakSelf = self
            
            // Try to download this image
            NetworkServices.sharedInstance.downloadFile(imageURL,
                fileName: nil,
                headers: nil,
                blocksIdentifer: blockIdentifier,
                progress: progressBlock,
                success: { (url, saveFilePath) -> Void in
                    
                    DispatchQueue.global(qos: DispatchQoS.background.qosClass).async(execute: { () -> Void in
                        let image = UIImage(contentsOfFile: saveFilePath)?.decodeImage()
                        
                        if (image != nil) {
                            // Save this image to cache
                            MemCacheManager.sharedInstance.cacheImage(image!, forKey: cacheKey)
                        }
                        
                        // Set image after load on memory
                        DispatchQueue.main.async(execute: { () -> Void in
                            weakSelf?.setImage(image, for: state)
                            
                            completedBlock?(image)
                        })
                    })
                },
                failed: { (url, error, isCancelled) -> Void in
                    DLog("Cannot download image: \(error)")
                    completedBlock?(nil)
            })
        }
    }
    
    func setImage(_ imageURL: String, defaultImage: UIImage?, forState state: UIControlState) {
        self.setImage(imageURL, defaultImage: defaultImage, forState: state, progressBlock: nil, completed: nil)
    }
}
