//
//  MediaPlayerManager.swift
//  ChatApp
//
//  Created by Tam Nguyen Ngoc on 5/31/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit

class MediaPlayerManager: NSObject {
    // MARK: Properties
    
    var photoViewer: PhotoViewerView?
    
    var videoPlayer: VideoPlayerView?
    var videoPlayerMinimizedVisibleRect = CGRect.zero {
        didSet {
            if (self.videoPlayer != nil) {
                self.videoPlayer!.minimizeVisibleArea = self.videoPlayerMinimizedVisibleRect
            }
        }
    }
    
    // MARK: Class methods
    
    static let sharedInstance : MediaPlayerManager = {
        let instance = MediaPlayerManager()
        
        return instance
    }()
    
    // MARK: Method for image
    
    func displayImage(_ image: UIImage) {
        if (self.photoViewer != nil) {
            self.photoViewer!.dismissImageViewer(false)
            self.photoViewer = nil
        }
        
        self.photoViewer = PhotoViewerView.createPhotoViewer()
        self.photoViewer!.displayImage(image)
        
        // Present this viewer
        self.photoViewer!.presentImageViewer(true)
    }
    
    func displayImageFromURL(_ urlString: String) {
        if (self.photoViewer != nil) {
            self.photoViewer!.dismissImageViewer(false)
            self.photoViewer = nil
        }
        
        self.photoViewer = PhotoViewerView.createPhotoViewer()
        self.photoViewer!.displayImageURL(urlString)
        
        // Present this viewer
        self.photoViewer!.presentImageViewer(true)
    }
    
    // MARK: Method for video
    
    func playVideo(_ urlString: String, isStreaming: Bool) {
        if (self.videoPlayer == nil) {
            self.videoPlayer = VideoPlayerView.createVideoPlayer()
            self.videoPlayer!.minimizeVisibleArea = self.videoPlayerMinimizedVisibleRect
        } else {
            self.videoPlayer!.stop()
            
            /**
             * If this player is presented, we only need fullscreen it if currently is minimized
             * Else not: present this player
             */
            if (self.videoPlayer!.isPlayerPresented && self.videoPlayer!.isMinimized) {
                self.videoPlayer!.unminimizedPlayer(true)
            }
        }
        
        if (isStreaming) {
            self.videoPlayer!.playStreamingVideo(urlString)
        } else {
            self.videoPlayer!.playFile(urlString)
        }
        
        // Present this player
        self.videoPlayer!.presentVideoPlayer(true)
    }
}
