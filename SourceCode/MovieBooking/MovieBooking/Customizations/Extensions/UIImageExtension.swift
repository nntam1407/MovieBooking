//
//  UIImageExtension.swift
//  ChatApp
//
//  Created by Ngoc Tam Nguyen on 12/18/14.
//  Copyright (c) 2014 Ngoc Tam Nguyen. All rights reserved.
//

import Foundation
import UIKit
import Accelerate
import AssetsLibrary
import ImageIO

let radiansToDegrees: (CGFloat) -> CGFloat = {
    return $0 / (CGFloat(Double.pi) / 180.0)
}

let degreesToRadians: (CGFloat) -> CGFloat = {
    return $0 * (CGFloat(Double.pi) / 180.0)
}

extension UIImage {
    
    func decodeImage() -> UIImage? {
        
        if self.cgImage == nil {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        // No-op if the orientation is not already correct
        if self.imageOrientation != UIImageOrientation.up {
            // We need to calculate the proper transformation to make the image upright.
            // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.

            switch (self.imageOrientation) {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: self.size.width, y: self.size.height)
                transform = transform.rotated(by: CGFloat(Double.pi))
                break
                
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: self.size.width, y: 0)
                transform = transform.rotated(by: CGFloat(Double.pi/2.0))
                break
                
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: self.size.height)
                transform = transform.rotated(by: CGFloat(-Double.pi/2.0))
                break
                
            case .up, .upMirrored:
                break
            }
            
            switch (self.imageOrientation) {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: self.size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
                break
                
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: self.size.height, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
                break
                
            case .up, .down, .left, .right:
                break
            }
        }
        
        var decodedImage: UIImage? = self
        
        autoreleasepool { () -> () in
            // Now we draw the underlying CGImage into a new context, applying the transform
            // calculated above.
            let data = UnsafeMutableRawPointer.allocate(bytes: Int(self.size.width) * Int(self.size.height) * 4, alignedTo: 0)
            
            var context = CGContext(data: data,
                                    width: Int(self.size.width),
                                    height: Int(self.size.height),
                                    bitsPerComponent: self.cgImage!.bitsPerComponent,
                                    bytesPerRow: Int(self.size.width) * 4,
                                    space: self.cgImage!.colorSpace!,
                                    bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
            
            if (context == nil) {
                context = CGContext(data: data,
                                    width: Int(self.size.width),
                                    height: Int(self.size.height),
                                    bitsPerComponent: self.cgImage!.bitsPerComponent,
                                    bytesPerRow: Int(self.size.width) * 4,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            }
            
            if (context != nil) {
                context!.concatenate(transform)
                
                switch (self.imageOrientation) {
                case .left, .leftMirrored, .right, .rightMirrored:
                    // Grr...
                    context!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height,height: self.size.width))
                    break
                    
                default:
                    context!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width,height: self.size.height))
                    break
                }
                
                // And now we just create a new UIImage from the drawing context
                let decodedImageRef = context!.makeImage()
                decodedImage = UIImage(cgImage: decodedImageRef!)
            }
            
            // Free data
            free(data)
        }
        
        return decodedImage;
    }
    
    class func resizeImageFromFile(_ filePath: String, maxSize: CGFloat) -> UIImage? {
        var result: UIImage?
        let imageURL = URL(fileURLWithPath: filePath)
        
        if FileManager.default.fileExists(atPath: filePath) {
            let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil)
            
            let options = [kCGImageSourceCreateThumbnailWithTransform as String: true, kCGImageSourceCreateThumbnailFromImageAlways as String: true,
                kCGImageSourceShouldCache as String: false,
                kCGImageSourceShouldCacheImmediately as String: false,
                kCGImageSourceThumbnailMaxPixelSize as String: maxSize] as [String : Any]
            
            let imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource!, 0, options as CFDictionary?)
            result = UIImage(cgImage: imageRef!)
        }
        
        return result
    }
    
    func resizeImage(_ size: CGSize) -> UIImage? {
        let imageRef = self.cgImage
        let srcSize = CGSize(width: CGFloat((imageRef?.width)!), height: CGFloat((imageRef?.height)!))
        var dstSize = size
        
        if (srcSize.equalTo(size)) {
            return self
        }
        
        let scaleRatio = size.width / srcSize.width
        let orient = self.imageOrientation
        var transform = CGAffineTransform.identity
        
        switch (orient) {
        case UIImageOrientation.up:
            transform = CGAffineTransform.identity
            break
            
        case UIImageOrientation.upMirrored:
            transform = CGAffineTransform(translationX: srcSize.width, y: 0.0)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
            
        case UIImageOrientation.down: //EXIF = 3
            transform = CGAffineTransform(translationX: srcSize.width, y: srcSize.height);
            transform = transform.rotated(by: CGFloat(Double.pi));
            break;
            
        case UIImageOrientation.downMirrored: //EXIF = 4
            transform = CGAffineTransform(translationX: 0.0, y: srcSize.height);
            transform = transform.scaledBy(x: 1.0, y: -1.0);
            break;
            
        case UIImageOrientation.leftMirrored: //EXIF = 5
            dstSize = CGSize(width: dstSize.height, height: dstSize.width);
            transform = CGAffineTransform(translationX: srcSize.height, y: srcSize.width);
            transform = transform.scaledBy(x: -1.0, y: 1.0);
            transform = transform.rotated(by: 3.0 * CGFloat(Double.pi/2.0));
            break;
            
        case UIImageOrientation.left: //EXIF = 6
            dstSize = CGSize(width: dstSize.height, height: dstSize.width);
            transform = CGAffineTransform(translationX: 0.0, y: srcSize.width);
            transform = transform.rotated(by: 3.0 * CGFloat(Double.pi/2.0));
            break;
            
        case UIImageOrientation.rightMirrored: //EXIF = 7
            dstSize = CGSize(width: dstSize.height, height: dstSize.width);
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
            transform = transform.rotated(by: CGFloat(Double.pi/2.0));
            break;
            
        case UIImageOrientation.right: //EXIF = 8
            dstSize = CGSize(width: dstSize.height, height: dstSize.width);
            transform = CGAffineTransform(translationX: srcSize.height, y: 0.0);
            transform = transform.rotated(by: CGFloat(Double.pi/2.0));
            break;
        }
        
        // The actual resize: draw the image on a new context, applying a transform matrix
        UIGraphicsBeginImageContextWithOptions(dstSize, false, self.scale)
        let contextRef = UIGraphicsGetCurrentContext()
        
        if (orient == UIImageOrientation.right || orient == UIImageOrientation.left) {
            contextRef?.scaleBy(x: -scaleRatio, y: scaleRatio)
            contextRef?.translateBy(x: -srcSize.height, y: 0)
        } else {
            contextRef?.scaleBy(x: scaleRatio, y: -scaleRatio)
            contextRef?.translateBy(x: 0, y: -srcSize.height)
        }
        
        contextRef?.concatenate(transform)
        
        // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
        UIGraphicsGetCurrentContext()?.draw(imageRef!, in: CGRect(x: 0, y: 0, width: srcSize.width, height: srcSize.height));
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resizedImage;
    }
    
    func resizedImageToFitInSize(_ boundingSize: CGSize, scaleIfSmaller scale: Bool) -> UIImage? {
        // get the image size (independant of imageOrientation)
        var inputSize = boundingSize
        let imageRef = self.cgImage;
        let srcSize = CGSize(width: CGFloat((imageRef?.width)!), height: CGFloat((imageRef?.height)!));
        
        // adjust boundingSize to make it independant on imageOrientation too for farther computations
        let orient = self.imageOrientation;
        
        switch (orient) {
        case UIImageOrientation.left, UIImageOrientation.right, UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            inputSize = CGSize(width: inputSize.height, height: inputSize.width);
            break;
        default:
            break
        }
        
        // Compute the target CGRect in order to keep aspect-ratio
        var dstSize = inputSize;
        
        if ( !scale && (srcSize.width < inputSize.width) && (srcSize.height < inputSize.height) ) {
            dstSize = srcSize; // no resize (we could directly return 'self' here, but we draw the image anyway to take image orientation into account)
        } else {
            let wRatio = inputSize.width / srcSize.width;
            let hRatio = inputSize.height / srcSize.height;
            
            if (wRatio < hRatio) {
                dstSize = CGSize(width: inputSize.width, height: floor(srcSize.height * wRatio));
            } else {
                dstSize = CGSize(width: floor(srcSize.width * hRatio), height: inputSize.height);
            }
        }
        
        return self.resizeImage(dstSize);
    }
    
    func maskImageColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.translateBy(x: 0, y: self.size.height);
        contextRef?.scaleBy(x: 1.0, y: -1.0);
        contextRef?.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        contextRef?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        contextRef?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func cropImage(_ rect: CGRect) -> UIImage {
        var destRect = rect
        
        if (destRect.origin.x < 0) {
            destRect.origin.x = 0
        } else if (destRect.origin.x > self.size.width) {
            destRect.origin.x = self.size.width
        }
        
        if (destRect.origin.y < 0) {
            destRect.origin.y = 0
        } else if (destRect.origin.y > self.size.height) {
            destRect.origin.y = self.size.height
        }
        
        if (destRect.origin.x + destRect.size.width > self.size.width) {
            destRect.size.width = self.size.width - destRect.origin.x
        }
        
        if (destRect.origin.y + destRect.size.height > self.size.height) {
            destRect.size.height = self.size.height - destRect.origin.y
        }
        
        if (rect.size.width != self.size.width || rect.size.height != self.size.height) {
            let imageRef = self.cgImage?.cropping(to: destRect)
            return UIImage(cgImage: imageRef!)
        } else {
            return self
        }
    }
    
    func blurImage(_ blurRadius: Float, tintColor: UIColor?, maskImage: UIImage?) -> UIImage? {
        let saturationDeltaFactor: Float = 1.8
//        var tintColor = tintColor
        
//        if (tintColor == nil) {
//            tintColor = UIColor(white: 1.0, alpha: 0.3)
//        }
        
        let hasBlur = blurRadius > Float.ulpOfOne
        let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > Float.ulpOfOne
        
        let inputCGImage = self.cgImage
        let inputImageScale = self.scale
        let inputBitmapInfo = inputCGImage?.bitmapInfo
        let inputImageAlphaInfo = (inputBitmapInfo?.rawValue)! & CGBitmapInfo.alphaInfoMask.rawValue
        
        let outputImageSizeInPoint = self.size
        let outputImageRectInPoint = CGRect(x: 0, y: 0, width: outputImageSizeInPoint.width, height: outputImageSizeInPoint.height)
        
        // Set up output context
        var useOpaqueContext = false
        
        if (inputImageAlphaInfo == CGImageAlphaInfo.none.rawValue ||
            inputImageAlphaInfo == CGImageAlphaInfo.noneSkipFirst.rawValue ||
            inputImageAlphaInfo == CGImageAlphaInfo.noneSkipLast.rawValue) {
                useOpaqueContext = true
        }
        
        UIGraphicsBeginImageContextWithOptions(outputImageRectInPoint.size, useOpaqueContext, inputImageScale)
        let outputContext = UIGraphicsGetCurrentContext()
        outputContext?.scaleBy(x: 1.0, y: -1.0)
        outputContext?.translateBy(x: 0, y: -outputImageRectInPoint.size.height)
        
        if hasBlur || hasSaturationChange {
            var effectInBuffer = vImage_Buffer(data: nil, height: 0, width: 0, rowBytes: 0)
            var scratchBuffer1 = vImage_Buffer(data: nil, height: 0, width: 0, rowBytes: 0)
            
            var inputBuffer = vImage_Buffer(data: nil, height: 0, width: 0, rowBytes: 0)
            var outputBuffer = vImage_Buffer(data: nil, height: 0, width: 0, rowBytes: 0)
            
            var format = vImage_CGImageFormat(bitsPerComponent: 8,
                bitsPerPixel: 32,
                colorSpace: nil,
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
                version: 0,
                decode: nil,
                renderingIntent: CGColorRenderingIntent.defaultIntent)
            
            let error = vImageBuffer_InitWithCGImage(&effectInBuffer, &format, nil, self.cgImage!, 0)
            
            if (error != kvImageNoError) {
                DLog("Error");
                UIGraphicsEndImageContext()
                
                return nil
            }
            
            vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, 0)
            inputBuffer = effectInBuffer
            outputBuffer = scratchBuffer1
            
            if (hasBlur) {
                var inputRadius = blurRadius * Float(inputImageScale)
                if (inputRadius - 2 < Float.ulpOfOne) {
                    inputRadius = 2
                }
                
                let value = floor(inputRadius * 3.0 * sqrt(2.0 * Float(Double.pi)) / 4.0 + 0.5) / 2.0
                var radius = UInt32(value)
                radius |= 1 // force radius to be odd so that the three box-blur methodology works
                
                let tempBufferSize = vImageBoxConvolve_ARGB8888(&inputBuffer, &outputBuffer, nil, 0, 0, radius, radius, nil, vImage_Flags(kvImageGetTempBufferSize | kvImageEdgeExtend))
                let tempBuffer = malloc(Int(tempBufferSize))
                
                vImageBoxConvolve_ARGB8888(&inputBuffer, &outputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&outputBuffer, &inputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&inputBuffer, &outputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                
                free(tempBuffer)
                
                let temp = inputBuffer
                inputBuffer = outputBuffer
                outputBuffer = temp
            }
            
            // Draw image
//            var effectCGImage = vImageCreateCGImageFromBuffer(&inputBuffer, &format, nil, nil, vImage_Flags(kvImageNoAllocate), nil).takeRetainedValue() as CGImage?
            
            var effectCGImage = vImageCreateCGImageFromBuffer(&inputBuffer,
                                                              &format,
                                                              { (userData, bufferData) in
                                                                if bufferData != nil {
                                                                    free(bufferData!)
                                                                }
                },
                                                              nil,
                                                              vImage_Flags(kvImageNoAllocate), nil).takeRetainedValue() as CGImage?
            
            if (effectCGImage == nil) {
                effectCGImage = vImageCreateCGImageFromBuffer(&inputBuffer, &format, { (userData, bufferData) in
                    if bufferData != nil {
                        free(bufferData!)
                    }
                    }, nil, vImage_Flags(kvImageNoFlags), nil).takeUnretainedValue() as CGImage?
                
                free(inputBuffer.data)
            }
            
            if (maskImage != nil) {
                outputContext?.draw(inputCGImage!, in: outputImageRectInPoint)
            }
            
            // draw effect image
            outputContext?.saveGState();
            
            if (maskImage != nil) {
                outputContext?.clip(to: outputImageRectInPoint, mask: maskImage!.cgImage!);
            }
            
            outputContext?.draw(effectCGImage!, in: outputImageRectInPoint);
            outputContext?.restoreGState()
            
            // Cleanup
            free(outputBuffer.data)
            
        } else {
            // draw base image
            outputContext?.draw(inputCGImage!, in: outputImageRectInPoint)
        }
        
        // Add in color tint.
        if (tintColor != nil)
        {
            outputContext?.saveGState();
            outputContext?.setFillColor(tintColor!.cgColor);
            outputContext?.fill(outputImageRectInPoint);
            outputContext?.restoreGState();
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return outputImage;
    }
}
