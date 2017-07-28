//
//  UploadItem.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/31/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

typealias uploadSuccessBlock =  (_ response: NSDictionary?) -> Void
typealias uploadFailedBlock =  (_ error: NSError, _ isCancelled: Bool) -> Void
typealias uploadProgressBlock =  (_ bytesSent: Int64, _ totalBytesSent: Int64, _ totalBytesExpectedToSend: Int64) -> Void

class UploadRequestItem: NSObject {
    
    var urlString: String = ""
    var uploadTask: URLSessionUploadTask?
    var isCancelled = false
    var data = NSMutableData()
    var response: NSDictionary?
    
    // Blocks handlers
    var progressBlock: uploadProgressBlock?
    var successBlock: uploadSuccessBlock?
    var failedBlock: uploadFailedBlock?
    
    // Uploaded percent
    var uploadedPercent: CGFloat {
        get {
            if (self.uploadTask == nil) {
                return 0
            } else if (self.uploadTask!.countOfBytesExpectedToSend == 0) {
                return 0
            } else {
                return CGFloat(self.uploadTask!.countOfBytesSent) / CGFloat(self.uploadTask!.countOfBytesExpectedToSend)
            }
        }
    }
    
    // MARK: Override methods
    
    init(urlString: String, progress: uploadProgressBlock?, success: uploadSuccessBlock?, failed: uploadFailedBlock?) {
        super.init()
        
        self.urlString = urlString
        
        self.progressBlock = progress
        self.successBlock = success
        self.failedBlock = failed
    }
    
    deinit {
        self.uploadTask = nil
        
        // Remove all blocks
        self.removeAllBlocks()
    }
    
    // MARK: Public methods
    
    func resume() {
        if (self.uploadTask != nil) {
            self.uploadTask!.resume()
        }
    }
    
    func pause() {
        if (self.uploadTask != nil) {
            self.uploadTask!.suspend()
        }
    }
    
    func cancel() {
        self.isCancelled = true
        
        if (self.uploadTask != nil) {
            self.uploadTask!.cancel()
        } else {
            self.finishedUpload(NSError(domain: "FileServices.UploadItem", code: -1, userInfo: nil))
        }
        
        // Set nil for download task
        self.uploadTask = nil
    }
    
    func removeAllBlocks() {
        self.progressBlock = nil
        self.successBlock = nil
        self.failedBlock = nil
    }
    
    func didUploadData(_ bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.progressBlock?(bytesSent, totalBytesSent, totalBytesExpectedToSend)
            
            return
        })
    }
    
    func finishedUpload(_ error: NSError?) {
        var responseDicts: NSDictionary? = nil
        
        do {
            responseDicts = try JSONSerialization.jsonObject(with: self.data as Data, options: JSONSerialization.ReadingOptions()) as? NSDictionary
        } catch _ {
            // Fatal error
        }
        
        // Set response dict
        self.response = responseDicts
        
        DispatchQueue.main.async(execute: { () -> Void in
            if (error == nil) {
                self.successBlock?(responseDicts)
            } else {
                self.failedBlock?(error!, self.isCancelled)
            }
            
            // Remove block
            self.removeAllBlocks()
        })
    }
}
