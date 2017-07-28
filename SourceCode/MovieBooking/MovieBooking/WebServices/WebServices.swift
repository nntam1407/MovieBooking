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
    case ok = 200
    case created = 201
    case accepted = 202
    case found = 302
    case errorNotAcceptable = 406
    case errorBadRequest = 400
    case errorAuthenticated = 401
    case errorForbidden = 403
    case errorNotFound = 404
    case errorUnsupportMediaType = 415
}

let ResponseSuccessStatusCodes = [ResponseStatusCode.ok.rawValue,
                                  ResponseStatusCode.created.rawValue,
                                  ResponseStatusCode.accepted.rawValue]

class WebServices: NSObject {
    
    // MARK: Properties
    
    var baseURL = kWebServiceBaseURL
    var deviceToken: String? = nil
    
    // MARK: Override methods
    
    override init() {
        super.init()
        
        // Try to setup default header
        self.setupDefaultHeaders()
    }
    
    // MARK: Static methods
    
    static let sharedInstance: WebServices = {
        let instance = WebServices()
        
        // Setup some code here
        
        // Return
        return instance
    }()
    
    // MARK: Private methods
    
    private func setupDefaultHeaders() {
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["Content-Type"] = "application/json"
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["app-name"] = kAppName
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["app-version"] = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["device-id"] = UIDevice.current.identifierForVendor?.uuidString
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["device-name"] = UIDevice.current.name
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["device-model"] = UIDevice.current.model
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["device-token"] = self.deviceToken
        
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["os-name"] = "iOS"
        NetworkServices.sharedInstance.defaultRestAPIRequestHeaders["os-version"] = UIDevice.current.systemVersion
    }
    
    internal func createRequestURL(_ urlPath: String) -> String {
        let result = self.baseURL + urlPath
        
        return result
    }
    
    /**
     Method parse and check status code response from server
     Return true if statusCode is 200 or 201, 202
     */
    private func checkStatusCodeFromResponse(_ response: NSDictionary?) -> Bool {
        let status = response?["status"] as? Int
        
        if (status != nil) {
            if (ResponseSuccessStatusCodes.contains(status!)) {
                return true
            }
        }
        
        return false
    }
    
    /**
     Method return general error
     */
    func generalError(message: String?, code: Int?) -> NSError {
        if message == nil {
            return NSError(domain: "Ahacho Business",
                           code: code != nil ? code! : ResponseStatusCode.errorDefault.rawValue,
                           userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Unfortunately we are unable to process your submission. Please try again later. We apologise for the inconvenience.", comment: "")])
        } else {
            return NSError(domain: "Ahacho Business",
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
                                                    if (self.checkStatusCodeFromResponse(response)) {
                                                        
                                                        // Call success block
                                                        success?(url, response)
                                                        
                                                    } else {
                                                        let statusCode = response?.intValueForKey("code")
                                                        let message = response?.stringValueForKey("message")
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
                                                                if (self.checkStatusCodeFromResponse(response)) {
                                                                    
                                                                    // Call success block
                                                                    success?(response)
                                                                    
                                                                } else {
                                                                    let statusCode = response?.intValueForKey("code")
                                                                    let message = response?.stringValueForKey("message")
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
