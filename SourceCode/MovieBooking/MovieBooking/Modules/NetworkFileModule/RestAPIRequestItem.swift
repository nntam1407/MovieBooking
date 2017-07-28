//
//  RestAPIRequestItem.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/11/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

typealias restRequestSuccessBlock =  (_ url: String, _ response: NSDictionary?) -> Void
typealias restRequestFailedBlock =  (_ url: String, _ error: NSError, _ isCancelled: Bool) -> Void

class RestAPIRequestItem: NSObject {
    var urlString: String = ""
    var dataTask: URLSessionDataTask?
    var isCancelled = false
    var data = NSMutableData()
    var response: NSDictionary?
    
    // Blocks handlers
    var successBlock: restRequestSuccessBlock?
    var failedBlock: restRequestFailedBlock?
    
    // MARK: Override methods
    
    init(urlString: String, success: restRequestSuccessBlock?, failed: restRequestFailedBlock?) {
        super.init()
        
        self.urlString = urlString
        self.successBlock = success
        self.failedBlock = failed
    }
    
    deinit {
        self.dataTask = nil
        
        // Remove all blocks
        self.removeAllBlocks()
    }
    
    // MARK: Public methods
    
    func resume() {
        if (self.dataTask != nil) {
            self.dataTask!.resume()
        }
    }
    
    func pause() {
        if (self.dataTask != nil) {
            self.dataTask!.suspend()
        }
    }
    
    func cancel() {
        self.isCancelled = true
        
        if (self.dataTask != nil) {
            self.dataTask!.cancel()
        } else {
            self.finishedRequest(NSError(domain: "FileServices.RestAPIRequestItem", code: -1, userInfo: nil))
        }
        
        // Set nil for download task
        self.dataTask = nil
    }
    
    func removeAllBlocks() {
        self.successBlock = nil
        self.failedBlock = nil
    }
    
    func finishedRequest(_ error: NSError?) {
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
                self.successBlock?(self.urlString, self.response)
            } else {
                self.failedBlock?(self.urlString, error!, self.isCancelled)
            }
            
            // Remove block
            self.removeAllBlocks()
        })
    }
}
