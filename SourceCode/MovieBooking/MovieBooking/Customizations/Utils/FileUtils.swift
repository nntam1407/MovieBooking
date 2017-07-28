//
//  FileUtils.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 1/28/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit
import MobileCoreServices

class FileUtils: NSObject {
    
    class func mimeTypeForExtension(_ fileExtension: String) -> String {
        let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil);
        let str = UTTypeCopyPreferredTagWithClass(UTI!.takeUnretainedValue(), kUTTagClassMIMEType);
        
        if (str == nil) {
            return "application/octet-stream";
        } else {
            return str!.takeUnretainedValue() as String
        }
    }
    
    // Get application document directory
    class func applicationDocumentDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }
    
    class func isExist(_ filePath: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: filePath)
    }
    
    class func createFolderAtPath(_ path: String) -> Bool {
        let fileManager = FileManager.default
        
        if (!fileManager.fileExists(atPath: path)) {
            var error: NSError? = nil
            
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error1 as NSError {
                error = error1
            }
            
            if (error != nil) {
                DLog("Cannot create folder at path: \(path)\nError: \(error!.localizedDescription)")
                return false
            }
        }
        
        return true
    }
    
    class func fileSize(_ filePath: String) -> UInt {
        let fileManager = FileManager.default
        
        if (FileUtils.isExist(filePath)) {
            let fileAttrs: [FileAttributeKey: Any]?
            do {
                fileAttrs = try fileManager.attributesOfItem(atPath: filePath)
            } catch _ {
                fileAttrs = nil
            }
            
            if (fileAttrs != nil) {
                let fileSize: AnyObject? = fileAttrs![FileAttributeKey.size] as AnyObject
                return fileSize != nil ? fileSize as! UInt : 0
            }
        }
        
        return 0
    }
    
    class func copyFile(_ srcPath: String, destPath: String) -> Bool {
        let fileManager = FileManager.default
        var error: NSError? = nil
        
        do {
            try fileManager.copyItem(atPath: srcPath, toPath: destPath)
        } catch let error1 as NSError {
            error = error1
        }
        
        if (error != nil) {
            DLog("Cannot copy file.\nError: \(error!.localizedDescription)")
            return false
        }
        
        return true
    }
    
    class func moveFile(_ srcPath: String, destPath: String) -> Bool {
        // First copy file
        if (FileUtils.copyFile(srcPath, destPath: destPath)) {
            // Delete src file
            let fileManager = FileManager.default
            var error: NSError? = nil
            
            do {
                try fileManager.removeItem(atPath: srcPath)
            } catch let error1 as NSError {
                error = error1
            }
            
            if (error != nil) {
                DLog("Move file. Cannot delete src file.\nError: \(error!.localizedDescription)")
            }
        } else {
            return false
        }
        
        return true
    }
    
    class func deleteFile(_ filePath: String) -> Bool {
        let fileManager = FileManager.default
        var error: NSError? = nil
        
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error1 as NSError {
            error = error1
        }
        
        if (error != nil) {
            DLog("Cannot delete file.\nError: \(error!.localizedDescription)")
            return false
        }
        
        return true
    }
}
