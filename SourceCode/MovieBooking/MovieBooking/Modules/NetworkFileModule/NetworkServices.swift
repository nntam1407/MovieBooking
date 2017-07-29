//
//  FileServices.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/26/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

let kDownloadDataDirectory = "/DownloadData"
let kUploadTempDirectory = "/UploadTemp"
let kDefaultTempFileExtension = "temp"
let kDownloadSessionIdentifer = "app.download.session"
let kUploadSessionIdentifer = "app.upload.session"

let kMaxFileDownloadingNumber = 5
let kMaxFileUploadingNumber = 1
let kMaxRestAPIRequestCount = 10

let kRestAPIRequestTimeout = 20 // 20s

let kMultipartDataBoundary = "Qe43VdbVVaGtkkMd"

// Define error code
enum NetworkServicesErrorCode: Int {
    case existing = -9998
    case other = -9999
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

class NetworkServices: NSObject, URLSessionDataDelegate, URLSessionDownloadDelegate {
    // MARK: Properties
    private var downloadSession: Foundation.URLSession?
    private var uploadSession: Foundation.URLSession?
    private var restAPISession: Foundation.URLSession?
    
    private var downloadItems = [String: DownloadRequestItem]() // Key is URL string
    private var uploadItems = [String: UploadRequestItem]()
    private var restRequestItems = [String: RestAPIRequestItem]()
    
    var defaultDownloadRequestHeaders = [String: String?]()
    var defaultUploadRequestHeaders = [String: String?]()
    var defaultRestAPIRequestHeaders = [String: String?]()
    
    var timeoutInterval: TimeInterval = 20 // default is 20s
    
    // MARK: Override methods
    
    override init() {
        super.init()
        
        // Init for download session
        let configs: URLSessionConfiguration?
        
        if #available(iOS 8.0, *) {
            configs = URLSessionConfiguration.background(withIdentifier: kDownloadSessionIdentifer)
        } else {
            configs = URLSessionConfiguration.backgroundSessionConfiguration(kDownloadSessionIdentifer)
        }
        
        configs!.httpMaximumConnectionsPerHost = kMaxFileDownloadingNumber
        configs!.allowsCellularAccess = true
        self.downloadSession = Foundation.URLSession(configuration: configs!, delegate: self, delegateQueue: nil)

        // Init for upload session
        let uploadConfigs: URLSessionConfiguration?
        
        if #available(iOS 8.0, *) {
            uploadConfigs = URLSessionConfiguration.background(withIdentifier: kUploadSessionIdentifer)
        } else {
            uploadConfigs = URLSessionConfiguration.backgroundSessionConfiguration(kUploadSessionIdentifer)
        }
        
        uploadConfigs!.httpMaximumConnectionsPerHost = kMaxFileUploadingNumber
        uploadConfigs!.allowsCellularAccess = true
        self.uploadSession = Foundation.URLSession(configuration: uploadConfigs!, delegate: self, delegateQueue: nil)
        
        // Init for restAPI session
        let restAPISessionCofigs = URLSessionConfiguration.default
        
        restAPISessionCofigs.httpMaximumConnectionsPerHost = kMaxRestAPIRequestCount
        restAPISessionCofigs.requestCachePolicy = .reloadIgnoringCacheData
        restAPISessionCofigs.allowsCellularAccess = true
        restAPISessionCofigs.timeoutIntervalForRequest = TimeInterval(kRestAPIRequestTimeout)
        restAPISessionCofigs.timeoutIntervalForResource = TimeInterval(kRestAPIRequestTimeout)
        self.restAPISession = Foundation.URLSession(configuration: restAPISessionCofigs, delegate: self, delegateQueue: nil)
    }
    
    // MARK: Class methods
    
    static let sharedInstance : NetworkServices = {
        let instance = NetworkServices()
        
        return instance
    }()
    
    // MARK: Support methods
    
    private func getDirectory(_ subPath: String?) -> String {
        var documentDir = FileUtils.applicationDocumentDirectory().path

        if (subPath != nil) {
            documentDir = (documentDir as NSString).appendingPathComponent(subPath!)
        }
        
        // Try to create this folder if is not exist
        _ = FileUtils.createFolderAtPath(documentDir)
        
        return documentDir
    }
    
    private func appendRequestHeader(_ request: inout URLRequest, headers: [String: String?]?) {
        if (headers != nil && headers!.count > 0) {
            for (key, value) in headers! {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
    /**
        Method cancel request include download task, upload task and rest API task
    */
    func cancelRequest(_ identifier: String) {
        // Download task
        let downloadItem = self.downloadItems[identifier]
        downloadItem?.cancel()
        
        // Upload task
        let uploadItem = self.uploadItems[identifier]
        uploadItem?.cancel()
        
        // Rest API task
        let restItem = self.restRequestItems[identifier]
        restItem?.cancel()
    }
    
    // MARK: Download's methods
    
    func getDownloadDirectory() -> String {
        return self.getDirectory(kDownloadDataDirectory)
    }
    
    class func generateDownloadFileName(_ urlString: String) -> String {
        return urlString.hashMD5() + "." + kDefaultDownloadFileExtension
    }
    
    /**
        Method download file.
    
        - urlString: url string of file download
        - fileName: name of file will be saved in local storage after downloaded
        - headers: some headers value for request
        - blocksIdentifer: identifer of blocks input, we will use this info to remove only this blocks after if we want
     */
    func downloadFile(_ urlString: String,
        fileName: String?,
        headers: [String: String?]?,
        blocksIdentifer: String,
        progress: downloadProgressBlock?,
        success: downloadSuccessBlock?,
        failed: downloadFailedBlock?) {
        
            // Cheat for swift 3 because it has removed var in function parameter
            var fileName = fileName
        
            // Get file name if null
            if (fileName == nil || (fileName!).characters.count == 0) {
                fileName = NetworkServices.generateDownloadFileName(urlString)
            }
            
            // First check if this file is already downloaded, we won't download again
            let saveFilePath = (self.getDownloadDirectory() as NSString).appendingPathComponent(fileName!)
            
            if (FileUtils.isExist(saveFilePath)) {
                // Return success block
                success?(urlString, saveFilePath)
                return
                
            } else {
                // Create NSURL from file url string for new download
                let fileURL = URL(string: urlString)
                
                if (fileURL != nil) {
                    var downloadItem = self.downloadItems[urlString]
                    
                    if (downloadItem == nil) {
                        downloadItem = DownloadRequestItem(fileName: fileName, urlString: urlString)
                        self.downloadItems[urlString] = downloadItem!
                        
                        // Start new downnload task, then Assign file name for task description. After downloaded, we will use this description to save file
                        var request = URLRequest(url: fileURL!)
                        request.timeoutInterval = self.timeoutInterval
                        self.appendRequestHeader(&request, headers: self.defaultDownloadRequestHeaders)
                        self.appendRequestHeader(&request, headers: headers)
                        
                        // Start download task
                        let downloadTask = self.downloadSession!.downloadTask(with: request)
                        downloadItem!.downloadTask = downloadTask
                        
                        // Start download
                        downloadTask.resume()
                    }
                    
                    // Append handle blocks for downloadItem
                    downloadItem!.appendBlocks(blocksIdentifer, progress: progress, success: success, failed: failed)
                } else {
                    // Failed block
                    if (failed != nil) {
                        failed!(urlString, NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: nil), false)
                    }
                }
            }
    }
    
    func cancelDownload(_ urlString: String) {
        let downloadItem = self.downloadItems[urlString]
        
        if (downloadItem != nil) {
            downloadItem!.cancel()
        }
    }
    
    /**
        Function remove handle block of download with urlString.
        
        - urlString: urlString of current download file. nil if remove all blocks of owner object
        - blocksIdentifer: nil if you want remove all blocks. Identifer if you want remove only exactly blocks
        
        If both urlString and blockOnwerObject is nil: remove all blocks of all download items
    */
    func removeDownloadBlocks(_ urlString: String?, blocksIdentifer: String?) {
        if (urlString != nil) {
            // Get download item
            let downloadItem = self.downloadItems[urlString!]
            
            if (blocksIdentifer == nil) {
                downloadItem?.removeAllBlocks()
            } else {
                downloadItem?.removeBlocks(blocksIdentifer!)
            }
        } else {
            for item in self.downloadItems {
                if (blocksIdentifer == nil) {
                    item.1.removeAllBlocks()
                } else {
                    item.1.removeBlocks(blocksIdentifer!)
                }
            }
        }
    }
    
    // MARK: Upload methods
    
    func uploadTempDirectory() -> String {
        return self.getDirectory(kUploadTempDirectory)
    }
    
    /**
        Methods support upload file
        Upload does not support multi blocks like download
    
        - indentifer: for recorgnize uploading item
     */
    func uploadFile(_ urlString: String,
        filePath: String,
        headers: [String: String?]?,
        httpMethod: HTTPMethod,
        identifer: String,
        success: uploadSuccessBlock?,
        progress: uploadProgressBlock?,
        failed: uploadFailedBlock?) {
        
            // Check upload identifer. If exist, return error
            if (self.uploadItems[identifer] != nil) {
                failed?(NSError(domain: "FileServices", code: NetworkServicesErrorCode.existing.rawValue, userInfo: nil), false)
                
                return
            }
            
            // Check if this file is not exist
            if (!FileUtils.isExist(filePath)) {
                failed?(NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil), false)
                
                return
            }
            
            // Create URL from URLString
            let uploadURL = URL(string: urlString)
            
            if (uploadURL == nil) {
                failed?(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: nil), false)
                
                return
            }
            
            // Now we will create request data to upload
            let uploadItem = UploadRequestItem(urlString: urlString, progress: progress, success: success, failed: failed)
            
            // Create upload request
            var request = URLRequest(url: uploadURL!)
            request.httpMethod = httpMethod.rawValue
            request.timeoutInterval = self.timeoutInterval
            self.appendRequestHeader(&request, headers: self.defaultUploadRequestHeaders)
            self.appendRequestHeader(&request, headers: headers)
            request.setValue("\(FileUtils.fileSize(filePath))", forHTTPHeaderField: "Content-Length")
            
            // Create upload task
            let uploadTask = self.uploadSession!.uploadTask(with: request as URLRequest, fromFile: URL(fileURLWithPath: filePath))
            uploadTask.taskDescription = identifer // store identifer in task description
            uploadItem.uploadTask = uploadTask
            
            // Store upload item in dictionary
            self.uploadItems[identifer] = uploadItem
            
            // Start upload task
            uploadTask.resume()
    }
    
    func uploadMultiPartRequest(_ url: String,
        headers: [String: String]?,
        multipartDatas: [MultipartData],
        httpMethod: HTTPMethod,
        identifer: String,
        success: uploadSuccessBlock?,
        progress: uploadProgressBlock?,
        failed: uploadFailedBlock?) {
            
            
            // Check upload identifer. If exist, return error
            if (self.uploadItems[identifer] != nil) {
                failed?(NSError(domain: "FileServices", code: NetworkServicesErrorCode.existing.rawValue, userInfo: nil), false)
                
                return
            }
            
            // Create URL from URLString
            let uploadURL = URL(string: url)
            
            if (uploadURL == nil) {
                failed?(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: nil), false)
                
                return
            }
            
            // Now we will create request data to upload
            let uploadItem = UploadRequestItem(urlString: url, progress: progress, success: success, failed: failed)
            
            // Create upload request
            var request = URLRequest(url: uploadURL!)
            request.httpMethod = httpMethod.rawValue
            request.timeoutInterval = self.timeoutInterval
            self.appendRequestHeader(&request, headers: self.defaultUploadRequestHeaders)
            self.appendRequestHeader(&request, headers: headers)
            
            // Create body data
            let bodyMultipartData = NSMutableData()
            
            for multipartData in multipartDatas {
                bodyMultipartData.append(multipartData.toMultipartData(kMultipartDataBoundary))
            }
            
            // Append end of multipart data
            bodyMultipartData.append(("--\(kMultipartDataBoundary)--\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            
            // Init data and header fo request
            request.httpBody = bodyMultipartData as Data
            request.setValue("\(bodyMultipartData.length)", forHTTPHeaderField: "Content-Length")
            request.setValue("multipart/form-data; boundary=\(kMultipartDataBoundary)", forHTTPHeaderField: "Content-Type")
            
            // Create upload task
            let uploadTask = self.uploadSession!.uploadTask(withStreamedRequest: request as URLRequest)
            uploadTask.taskDescription = identifer // store identifer in task description
            uploadItem.uploadTask = uploadTask
            
            // Store upload item in dictionary
            self.uploadItems[identifer] = uploadItem
            
            // Start upload task
            uploadTask.resume()
    }
    
    func cancelUpload(_ uploadIdentifer: String) {
        let uploadItem = self.uploadItems[uploadIdentifer]
        uploadItem?.cancel()
    }
    
    /**
        Method get percent uploaded with identifer
    */
    func getUploadedPercent(_ uploadIdentifer: String) -> CGFloat {
        let uploadItem = self.uploadItems[uploadIdentifer]
        
        if (uploadItem != nil) {
            return uploadItem!.uploadedPercent
        }
        
        return 0
    }
    
    // MARK: Rest API request
    
    func callRestAPI(_ url: String,
        headers: [String: String]?,
        bodyData: Data?,
        httpMethod: HTTPMethod,
        identifer: String,
        success: restRequestSuccessBlock?,
        failed: restRequestFailedBlock?) {
        
            // Check existing identifer, if have, override sussess and failed block
            if (self.restRequestItems[identifer] != nil) {
                let requestItem = self.restRequestItems[identifer]
                requestItem?.successBlock = success
                requestItem?.failedBlock = failed
                
                return
            }
            
            // Create URL from URLString
            let requestURL = URL(string: url)
            
            if (requestURL == nil) {
                failed?(url, NSError(domain: NSURLErrorDomain, code: NSURLErrorUnsupportedURL, userInfo: nil), false)
                
                return
            }
            
            // Now we will create request data to rest request
            let restRequestItem = RestAPIRequestItem(urlString: url, success: success, failed: failed)
            
            // Create upload request
            var request = URLRequest(url: requestURL!)
            request.httpMethod = httpMethod.rawValue
            request.httpBody = bodyData
            request.timeoutInterval = self.timeoutInterval
            self.appendRequestHeader(&request, headers: self.defaultRestAPIRequestHeaders)
            self.appendRequestHeader(&request, headers: headers)
            
            // Create upload task
            let dataTask = self.restAPISession!.dataTask(with: request)
            dataTask.taskDescription = identifer // store identifer in task description
            restRequestItem.dataTask = dataTask
            
            // Store rest request item in dictionary
            self.restRequestItems[identifer] = restRequestItem
            
            // Start data task
            dataTask.resume()
            
    }
    
    // MARK: Session delegates
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        if (session == self.downloadSession) {
            // Get download item
            let downloadItem = self.downloadItems[downloadTask.originalRequest!.url!.absoluteString]
            
            if (downloadItem != nil) {
                let saveFilePath = (self.getDownloadDirectory() as NSString).appendingPathComponent(downloadItem!.fileName)
                
                // Move file to destination path
                if (FileUtils.moveFile(location.path, destPath: saveFilePath)) {
                    downloadItem!.finishedDownload(saveFilePath, error: nil)
                } else {
                    downloadItem!.finishedDownload(nil, error: NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotMoveFile, userInfo: nil))
                }
                
                // Remove download item in dictionary
                self.downloadItems[downloadTask.originalRequest!.url!.absoluteString] = nil
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        // Get download item
        if (session == self.downloadSession) {
            let downloadItem = self.downloadItems[downloadTask.originalRequest!.url!.absoluteString]
            
            if (downloadItem != nil) {
                downloadItem!.didReceivedData(bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        if (session == self.uploadSession) {
            let uploadItem = self.uploadItems[task.taskDescription!]
            uploadItem?.didUploadData(bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if (session == self.uploadSession) {
            // TODO: Handle upload response from server
            
            // Try to get upload items
            let uploadItem = self.uploadItems[dataTask.taskDescription!]
            uploadItem?.data.append(data)
            
        } else if (session == self.restAPISession) {
            // TODO: Handle rest api response from server
            
            // Try to get upload items
            let restRequestItem = self.restRequestItems[dataTask.taskDescription!]
            restRequestItem?.data.append(data)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        // Handle download complete and failed
        if (session == self.downloadSession && error != nil) {
            
            // Get download item
            let downloadItem = self.downloadItems[task.originalRequest!.url!.absoluteString]
            
            if (downloadItem != nil) {
                downloadItem!.finishedDownload(nil, error: error as NSError?)
                
                // Remove download item in dictionary
                self.downloadItems[task.originalRequest!.url!.absoluteString] = nil
            }
            
        } else if (session == self.uploadSession) {
            // TODO: Hanlde upload task completed
            // Try to get upload items
            let uploadItem = self.uploadItems[task.taskDescription!]
            
            if (uploadItem != nil) {
                uploadItem!.finishedUpload(error as NSError?)
                
                // remove upload item in dictionary
                self.uploadItems[task.taskDescription!] = nil
            }
        } else if (session == self.restAPISession) {
            // Handle delegate for rest api request
            let restRequestItem = self.restRequestItems[task.taskDescription!]
            
            if (restRequestItem != nil) {
                restRequestItem!.finishedRequest(error as NSError?)
                
                // remove upload item in dictionary
                self.restRequestItems[task.taskDescription!] = nil
            }
        }
    }
}
