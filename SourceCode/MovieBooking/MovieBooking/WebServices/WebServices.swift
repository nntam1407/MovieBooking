//
//  WebServices.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/12/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

enum ResponseStatusCode: Int {
    case errorDefault = -1
}

class WebServices: NSObject {
    
    // MARK:
    // MARK: Properties
    
    var baseURL: String?
    var apiKey: String?
    
    // MARK:
    // MARK: Override methods
    
    override init() {
        super.init()
        
        // Try to setup default header
        self.setupDefaultHeaders()
    }
    
    // MARK:
    // MARK: Static methods
    
    static let sharedInstance: WebServices = {
        let instance = WebServices()
        
        // Setup some code here
        
        // Return
        return instance
    }()
    
    // MARK:
    // MARK: Private methods
    
    /// Set all default headers when calling APIs
    private func setupDefaultHeaders() {
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["Content-Type"] = "application/json"
    }
    
    /// Create request URL from URL path
    ///
    /// - Parameter urlPath: sub path of API URL
    /// - Returns: api url string
    private func createRequestURL(_ urlPath: String) -> String {
        if self.baseURL != nil {
            var result = self.baseURL! + urlPath
            
            if (self.apiKey != nil) {
                let index = result.characters.index(of: "?")
                
                if (index != nil) {
                    result.append("&api_key=\(self.apiKey!)")
                } else {
                    result.append("?api_key=\(self.apiKey!)")
                }
            }
            
            return result
        }
        
        return urlPath
    }
    
    
    /// Method parse and check status code response from server
    ///
    /// - Parameter response: response data as dictionary format
    /// - Returns: true if there is no status_code in response data
    private func checkIsResponseSuccess(_ response: NSDictionary?) -> Bool {
        if response?["status_code"] != nil {
            return false
        }
        
        return true
    }
    
    
    /// Sometime, because of some reason, we don't have any meaning error, so we need to present a general error for user
    ///
    /// - Parameters:
    ///   - message: error message if have
    ///   - code: error code if have
    /// - Returns: error as NSError object
    func generalError(message: String?, code: Int?) -> NSError {
        if message == nil {
            return NSError(domain: "MovieBooking",
                           code: code != nil ? code! : ResponseStatusCode.errorDefault.rawValue,
                           userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Unfortunately we are unable to process your submission. Please try again later. We apologise for the inconvenience.", comment: "")])
        } else {
            return NSError(domain: "MovieBooking",
                           code: code != nil ? code! : ResponseStatusCode.errorDefault.rawValue,
                           userInfo: [NSLocalizedDescriptionKey: message!])
        }
    }
    
    func callRequest(_ urlPath: String,
                     params: NSDictionary?,
                     identifer: String?,
                     httpMethod: HTTPMethod,
                     success: restRequestSuccessBlock?,
                     failed: restRequestFailedBlock?) {
        
        // Create request url string
        let requestUrl = self.createRequestURL(urlPath)
        
        // Create body data
        let bodyData = params?.toJsonString()?.data(using: String.Encoding.utf8)
        
        // Should set default header for each time call request
        self.setupDefaultHeaders()
        
        // Finally, call rest request
        NetworkServices.sharedInstance.callRestAPI(requestUrl,
                                                   headers: nil,
                                                   bodyData: bodyData,
                                                   httpMethod: httpMethod,
                                                   identifer: identifer != nil ? identifer! : Utils.uuid(),
                                                   success: { (url: String, response: NSDictionary?) -> Void in
                                                    
                                                    // Print success  data
                                                    DLog("Request: \(url):\nParams:\n\(String(describing: params))\nResponse:\n\(String(describing: response))")
                                                    
                                                    // We should check status code from response
                                                    if (self.checkIsResponseSuccess(response)) {
                                                        
                                                        // Call success block
                                                        success?(url, response)
                                                        
                                                    } else {
                                                        let statusCode = response?.intValueForKey("status_code")
                                                        let message = response?.stringValueForKey("status_message")
                                                        let error = self.generalError(message: message, code: statusCode)
                                                        
                                                        // Call failed block
                                                        failed?(url, error, false)
                                                    }
                                                    
        }) { (url: String, error: NSError, isCancelled: Bool) -> Void in
            
            // Print error data
            DLog("Request: \(url):\nParams:\n\(String(describing: params))\nError: \(error)")
            
            // Call failed block
            failed?(url, error, isCancelled)
        }
        
    }
    
    func callMultipartRequest(_ urlPath: String,
                              multipartDatas: [MultipartData],
                              identifer: String?,
                              httpMethod: HTTPMethod,
                              success: uploadSuccessBlock?,
                              progress: uploadProgressBlock?,
                              failed: uploadFailedBlock?) {
        
        // Create request url string
        let requestUrl = self.createRequestURL(urlPath)
        
        // Should set default header for each time call request
        self.setupDefaultHeaders()
        
        // Call API upload multipart data
        NetworkServices.sharedInstance.uploadMultiPartRequest(requestUrl,
                                                              headers: nil,
                                                              multipartDatas: multipartDatas,
                                                              httpMethod: httpMethod,
                                                              identifer: identifer != nil ? identifer! : Utils.uuid(),
                                                              success: { (response: NSDictionary?) -> Void in
                                                                // Print success data
                                                                DLog("Request: \(requestUrl):\n\(String(describing: response))")
                                                                
                                                                // We should check status code from response
                                                                if (self.checkIsResponseSuccess(response)) {
                                                                    
                                                                    // Call success block
                                                                    success?(response)
                                                                    
                                                                } else {
                                                                    let statusCode = response?.intValueForKey("status_code")
                                                                    let message = response?.stringValueForKey("status_message")
                                                                    let error = self.generalError(message: message, code: statusCode)
                                                                    
                                                                    // Call failed block
                                                                    failed?(error, false)
                                                                }
        },
                                                              progress: progress,
                                                              failed: { (error: NSError, isCancelled: Bool) -> Void in
                                                                // Print error data
                                                                DLog("Request: \(requestUrl):\nError: \(error)")
                                                                
                                                                // Call failed block
                                                                failed?(error, isCancelled)
        })
        
    }
    
    func cancelRequest(_ identifier: String) {
        NetworkServices.sharedInstance.cancelRequest(identifier)
    }
}
