//
//  UIImageViewDownloadExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 2/3/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

var objc_association_imageViewCurrentDownloadingUrlKey: UInt8 = 2

extension UIImageView {
    
    /// Save current downloading image URL. We will use this value to make sure display final image after decoded right with image URL. Because we will decoded image after download in background, so it will take long time and while wating, maybe have other image URL
    private var currentDownloadingImageURLString: String? {
        get {
            return objc_getAssociatedObject(self, &objc_association_imageViewCurrentDownloadingUrlKey) as? String
        } set {
            objc_setAssociatedObject(self, &objc_association_imageViewCurrentDownloadingUrlKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /**
        Function set image from URL for this image view
        We will use memory address for blocksIdentifer
    */
    func setImageURL(_ imageURL: String?,
        hightlightImageURL: String?,
        defaultImage: UIImage?,
        progressBlock: downloadProgressBlock?,
        completed completedBlock: ((_ image: UIImage?) -> Void)?) {
            
        // First remove all download blocks of previous download session
        NetworkServices.sharedInstance.removeDownloadBlocks(nil, blocksIdentifer: self.memoryAddressString())
        
        // Set default image
        self.image = defaultImage
        
        // Try to download image
        if (imageURL != nil) {
            
            // Save current image url
            self.currentDownloadingImageURLString = imageURL
            
            // First try to get image from cache
            let cacheKey = NetworkServices.generateDownloadFileName(imageURL!)
            let cacheImage = MemCacheManager.sharedInstance.getCacheImage(cacheKey)
            
            if (cacheImage != nil) {
                self.image = cacheImage
                
                completedBlock?(cacheImage)
            } else {
                
                // Create weak self to use in blocks
                weak var weakSelf = self
                
                // Try to download this image
                NetworkServices.sharedInstance.downloadFile(imageURL!,
                    fileName: nil,
                    headers: nil,
                    blocksIdentifer: self.memoryAddressString(),
                    progress: progressBlock,
                    success: { (url, saveFilePath) -> Void in

                        DispatchQueue.global(qos: DispatchQoS.default.qosClass).async(execute: { () -> Void in
                            let image = UIImage(contentsOfFile: saveFilePath)?.decodeImage()
                            
                            if (image != nil) {
                                // Save this image to cache
                                MemCacheManager.sharedInstance.cacheImage(image!, forKey: cacheKey)
                            }
                            
                            // Set image after load on memory
                            DispatchQueue.main.async(execute: { () -> Void in
                                // Do-nothing if now display for new URL
                                if url == weakSelf?.currentDownloadingImageURLString {
                                    if image == nil {
                                        weakSelf?.image = defaultImage
                                    } else {
                                        weakSelf?.image = image
                                    }
                                    
                                    completedBlock?(image)
                                }
                                
                                return
                            })
                        })
                    },
                    failed: { (url, error, isCancelled) -> Void in
                        DLog("Cannot download image: \(error)")
                        completedBlock?(nil)
                })
            }
        } else {
            completedBlock?(nil)
        }
        
        // Try to set hightlight image
        if (hightlightImageURL == nil) {
            self.highlightedImage = nil
        } else {
            
            // First try to get image from cache
            let cacheKey = NetworkServices.generateDownloadFileName(hightlightImageURL!)
            let cacheImage = MemCacheManager.sharedInstance.getCacheImage(cacheKey)
            
            if (cacheImage != nil) {
                self.highlightedImage = cacheImage
            } else {
                
                // Create weak self to use in blocks
                weak var weakSelf = self
                
                // Try to download hightligth image from url
                NetworkServices.sharedInstance.downloadFile(hightlightImageURL!,
                    fileName: nil,
                    headers: nil,
                    blocksIdentifer: self.memoryAddressString(),
                    progress: nil,
                    success: { (url, saveFilePath) -> Void in
                        
                        DispatchQueue.global(qos: DispatchQoS.default.qosClass).async(execute: { () -> Void in
                            let image = UIImage(contentsOfFile: saveFilePath)?.decodeImage()
                            
                            if (image != nil) {
                                // Save this image to cache
                                MemCacheManager.sharedInstance.cacheImage(image!, forKey: cacheKey)
                                
                                // Set image after load on memory
                                DispatchQueue.main.async(execute: { () -> Void in
                                    weakSelf?.highlightedImage = image
                                    return
                                })
                            }
                        })
                    },
                    failed: { (url, error, isCancelled) -> Void in
                        DLog("Cannot download image: \(error)")
                })
            }
        }
    }
    
    func setImageURL(_ imageURL: String?) {
        self.setImageURL(imageURL, hightlightImageURL: nil, defaultImage: nil, progressBlock: nil, completed: nil)
    }
    
    func setImageURL(_ imageURL: String?, defaultImage: UIImage?) {
        self.setImageURL(imageURL, hightlightImageURL: nil, defaultImage: defaultImage, progressBlock: nil, completed: nil)
    }
    
    func stopDownloadingImage() {
        let identifier = self.memoryAddressString()
        let currentURL = self.currentDownloadingImageURLString
        
        // First remove all download blocks of previous download session
        NetworkServices.sharedInstance.removeDownloadBlocks(nil, blocksIdentifer: identifier)
        
        if currentURL != nil {
            NetworkServices.sharedInstance.cancelDownload(currentURL!)
        }
    }
}
