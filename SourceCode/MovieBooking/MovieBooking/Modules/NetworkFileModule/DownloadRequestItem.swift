//
//  DownloadItem.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/31/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

let kDefaultDownloadFileExtension = "temp"

typealias downloadSuccessBlock =  (_ url: String, _ saveFilePath: String) -> Void
typealias downloadFailedBlock =  (_ url: String, _ error: NSError, _ isCancelled: Bool) -> Void
typealias downloadProgressBlock =  (_ url: String, _ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void

class DownloadRequestItem: NSObject {
    
    var fileName: String = ""
    var urlString: String = ""
    var downloadTask: URLSessionDownloadTask?
    var isCancelled = false
    
    var progressBlocks = [String: downloadProgressBlock]() // Key is block owner object address
    var successBlocks = [String: downloadSuccessBlock]() // Key is block owner object address
    var failedBlocks = [String: downloadFailedBlock]() // Key is block owner object address
    
    // MARK: Override methods
    
    init(fileName: String?, urlString: String) {
        super.init()
        
        self.urlString = urlString
        self.fileName = (fileName == nil || (fileName!).characters.count == 0) ? NetworkServices.generateDownloadFileName(urlString) : fileName!
    }
    
    deinit {
        self.downloadTask = nil
        self.removeAllBlocks()
    }
    
    // MARK: Public methods
    
    /**
        Menthod support add blocks handle to dictinary
    
        - blockOwnerObject: Object who want to handle block callbacks. We will use its address for key of dictionary
     */
    func appendBlocks(_ blocksIndentifer: String, progress: downloadProgressBlock?, success: downloadSuccessBlock?, failed: downloadFailedBlock?) {
        
        self.progressBlocks[blocksIndentifer] = progress
        self.successBlocks[blocksIndentifer] = success
        self.failedBlocks[blocksIndentifer] = failed
    }
    
    func removeBlocks(_ blocksIdentifer: String) {
        
        self.progressBlocks[blocksIdentifer] = nil
        self.successBlocks[blocksIdentifer] = nil
        self.failedBlocks[blocksIdentifer] = nil
        
    }
    
    func removeAllBlocks() {
        self.progressBlocks.removeAll(keepingCapacity: false)
        self.successBlocks.removeAll(keepingCapacity: false)
        self.failedBlocks.removeAll(keepingCapacity: false)
    }
    
    func resume() {
        if (self.downloadTask != nil) {
            self.downloadTask!.resume()
        }
    }
    
    func pause() {
        if (self.downloadTask != nil) {
            self.downloadTask!.suspend()
        }
    }
    
    func cancel() {
        self.isCancelled = true
        
        if (self.downloadTask != nil) {
            self.downloadTask!.cancel()
        } else {
            self.finishedDownload(nil, error: NSError(domain: "FileServices.DownloadItem", code: -1, userInfo: nil))
        }
        
        // Set nil for download task
        self.downloadTask = nil
    }
    
    func didReceivedData(_ bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        for progressBlock in self.progressBlocks {
            DispatchQueue.main.async(execute: { () -> Void in
                progressBlock.1(self.urlString, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
            })
        }
    }
    
    func finishedDownload(_ saveFilePath: String?, error: NSError?) {
        DispatchQueue.main.async(execute: { () -> Void in
            if (error == nil) {
                for successBlock in self.successBlocks {
                    successBlock.1(self.urlString, saveFilePath == nil ? "" : saveFilePath!)
                }
            } else {
                for failedBlock in self.failedBlocks {
                    failedBlock.1(self.urlString, error!, self.isCancelled)
                }
            }
            
            // Remove all blocks
            self.removeAllBlocks()
        })
    }
}



