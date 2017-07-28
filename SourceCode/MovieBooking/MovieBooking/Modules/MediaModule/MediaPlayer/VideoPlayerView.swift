//
//  VideoPlayerView.swift
//  ChatApp
//
//  Created by Tam Nguyen Ngoc on 5/29/15.
//  Copyright (c) 2015 Ngoc Tam Nguyen. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoPlayerView: UIView {
    
    private var topWindow: UIWindow?
    private var mediaPlayer: MPMoviePlayerController?
    
    @IBOutlet weak var playbackControlView: UIView!
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackTimeLabel: UILabel!
    @IBOutlet weak var playbackRemainTimeLabel: UILabel!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var doneButton: UIButton!
    
    var trackingTimer: Timer?
    var showPlaybackControlTimer: Timer?
    
    var isPlayerPresented: Bool {
        set {
            // Do nothing
        }
        get {
            return self.superview != nil
        }
    }
    
    // Properties for mimimize mode
    var minimizeSize = CGSize.zero
    var minimizeVisibleArea = CGRect.zero {
        didSet {
            self.refreshAndCorrectFrameForMinimizedView(true)
        }
    }
    
    var isMinimized = false
    var isDraggingSlider = false
    
    // Properties for moving minimized player
    var beginTouchPoint = CGPoint.zero

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Init base
        self.mediaPlayer = MPMoviePlayerController()
        self.mediaPlayer!.controlStyle = MPMovieControlStyle.none
        self.mediaPlayer!.isFullscreen = false
        self.mediaPlayer!.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.addSubview(self.mediaPlayer!.view)
        self.sendSubview(toBack: self.mediaPlayer!.view)
        
        // Set constrains for player view
        self.mediaPlayer!.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Init for playback control
        self.playbackSlider.setMaximumTrackImage(UIImage(named: "playback_slider_max")?.stretchableImage(withLeftCapWidth: 1, topCapHeight: 1), for: UIControlState())
        self.playbackSlider.setMinimumTrackImage(UIImage(named: "playback_slider_min")?.stretchableImage(withLeftCapWidth: 1, topCapHeight: 1), for: UIControlState())
        self.playbackSlider.setThumbImage(UIImage(named: "player_scrubber_thumb"), for: UIControlState())
        
        self.doneButton.layer.cornerRadius = 3.0
        self.doneButton.layer.borderWidth = 0.5
        self.doneButton.layer.borderColor = UIColor.white.cgColor
        self.doneButton.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        // Default minimize size is half of width of this view, and ratio is 16/9
        self.minimizeSize.width = self.frame.size.width/2
        self.minimizeSize.height = self.minimizeSize.width * 9 / 16
        
        // Add gesture recorgnize
        autoreleasepool { () -> () in
            // Pan gesture support for drap view
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(VideoPlayerView.panGestureEvent(_:)))
            panGesture.cancelsTouchesInView = true
            panGesture.maximumNumberOfTouches = 1
            self.addGestureRecognizer(panGesture)
        }
        
        // Register all notifications
        Utils.regNotif(self, selector: #selector(VideoPlayerView.playbackDidChangeState(_:)),
            name: NSNotification.Name.MPMoviePlayerPlaybackStateDidChange.rawValue,
            object: nil)
        
        Utils.regNotif(self, selector: #selector(VideoPlayerView.playbackDidChangeLoadingState(_:)),
            name: NSNotification.Name.MPMoviePlayerLoadStateDidChange.rawValue,
            object: nil)
        
        Utils.regNotif(self, selector: #selector(VideoPlayerView.playbackDidFinish(_:)),
            name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish.rawValue,
            object: nil)
        
        Utils.regNotif(self, selector: #selector(VideoPlayerView.applicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive.rawValue, object: nil)
    }
    
    deinit {
        // Remove all notification
        Utils.removeAllNotif(self)
        
        // Reduce memory in here
        self.mediaPlayer?.stop()
        self.mediaPlayer?.view.removeFromSuperview()
        self.mediaPlayer = nil
        
        self.topWindow = nil
    }
    
    // MARK: Class Methods
    
    class func createVideoPlayer() -> VideoPlayerView? {
        return Utils.loadView("VideoPlayerView") as? VideoPlayerView
    }
    
    // MARK: Handle view's events
    
    @objc func panGestureEvent(_ panGesture: UIPanGestureRecognizer) {
        // If this is not minimized mode, do nothing and return
        if (!self.isMinimized) {
            return
        }
        
        let currentTouchPoint = panGesture.location(in: self.topWindow)
        
        if (panGesture.state == UIGestureRecognizerState.began) {
            
            self.beginTouchPoint = currentTouchPoint
            
        } else if (panGesture.state == UIGestureRecognizerState.changed) {
            
            let panAmountX = self.beginTouchPoint.x - currentTouchPoint.x
            let panAmountY = self.beginTouchPoint.y - currentTouchPoint.y
            
            // Update frame of topWindow
            var windowFrame = self.topWindow!.frame
            windowFrame.origin.x -= panAmountX
            windowFrame.origin.y -= panAmountY
            self.topWindow?.frame = windowFrame
            
            // Check and corect frame in
            self.refreshAndCorrectFrameForMinimizedView(false)
            
            // Update beginTouchPoint
            self.beginTouchPoint = panGesture.location(in: self.topWindow)
        } else if (panGesture.state == UIGestureRecognizerState.ended ||
            panGesture.state == UIGestureRecognizerState.cancelled) {
        }
    }
    
    @IBAction func didTouchMinimizeButton(_ sender: AnyObject) {
        self.minimizePlayer(true)
        self.hidePlaybackControlView()
    }
    
    @IBAction func didTouchOnScreen(_ sender: AnyObject) {
        if (self.isMinimized) {
            self.unminimizedPlayer(true)
        } else {
            // Display playback control
            self.showPlaybackControlView()
        }
    }
    
    @IBAction func didTouchPlayButton(_ sender: AnyObject) {
        if (self.mediaPlayer!.playbackState != MPMoviePlaybackState.interrupted) {
            if (self.playButton.isSelected) {
                self.pause()
            } else {
                self.play()
            }
        } else {
            self.playButton.isSelected = false;
        }
    }
    
    @IBAction func playbackSlideDidTouchDown(_ sender: AnyObject) {
        self.pause()
        self.isDraggingSlider = true
    }
    
    @IBAction func playbackSliderDidTouchUp(_ sender: AnyObject) {
        if (!self.playButton.isSelected) {
            self.play()
        }
        
        self.isDraggingSlider = false
    }
    
    @IBAction func playbackSliderValueChanged(_ sender: AnyObject) {
        if (self.mediaPlayer!.playbackState != MPMoviePlaybackState.interrupted) {
            // Now we can seek to time
            let duration = self.mediaPlayer!.duration
            let timeInterval = TimeInterval(floor(Float(duration) * self.playbackSlider.value))
            
            self.seekToTime(timeInterval)
        }
    }
    
    @IBAction func didTouchDoneButton(_ sender: AnyObject) {
        self.stop()
        self.dismissVideoPlayer(true)
    }
    
    // MARK: UI Methods
    
    /**
     * Method display video player, default it will be added on top windows, fullscreen
     */
    func presentVideoPlayer(_ animated: Bool) {
        // Do nothing if this video currently added
        if (self.superview != nil) {
            return
        }
        
        self.isMinimized = false
        
        // Create new top window
        self.topWindow = UIWindow(frame: UIScreen.main.bounds)
        self.topWindow!.makeKeyAndVisible()
        
        // Move this windows on top of status bar
        self.topWindow!.windowLevel = UIWindowLevelStatusBar + 1
        
        self.frame = CGRect(x: 0, y: 0, width: self.topWindow!.frame.size.width, height: self.topWindow!.frame.size.height)
        self.topWindow!.addSubview(self)
        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        if (animated) {
            self.alpha = 0
            
            UIView.animate(withDuration: 0.45, delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.alpha = 1.0
                }, completion: { (finished) -> Void in
                    self.alpha = 1.0
            })
        } else {
            self.alpha = 1.0
        }
    }
    
    func dismissVideoPlayer(_ animated: Bool) {
        self.stop()
        
        if (self.superview == nil) {
            return
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.45, delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.alpha = 0
                }, completion: { (finished) -> Void in
                    self.removeFromSuperview()
                    self.topWindow = nil
            })
        } else {
            self.removeFromSuperview()
            self.topWindow = nil
        }
    }
    
    func minimizePlayer(_ animated: Bool) {
        if (self.isMinimized) {
            return
        }
        
        // Check visible area. If it is not set, default is this frame
        if (self.minimizeVisibleArea.equalTo(CGRect.zero)) {
            self.minimizeVisibleArea = self.frame
        }
        
        // Update minimized
        self.isMinimized = true
        
        // Hide playback control view
        self.playbackControlView.isHidden = true
        
        var windowFrame = self.topWindow!.frame
        windowFrame.size = self.minimizeSize
        windowFrame.origin.x = self.minimizeVisibleArea.origin.x + self.minimizeVisibleArea.width - windowFrame.width
        windowFrame.origin.y = self.minimizeVisibleArea.origin.y

        if (animated) {
            UIView.animate(withDuration: 0.3, delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.topWindow!.frame = windowFrame
                    self.topWindow!.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.topWindow!.frame = windowFrame
                    self.topWindow!.layoutIfNeeded()
            })
        } else {
            self.topWindow!.frame = windowFrame
            self.topWindow!.layoutIfNeeded()
        }
    }
    
    func unminimizedPlayer(_ animated: Bool) {
        if (!self.isMinimized) {
            return
        }
        
        // Update minimized
        self.isMinimized = false
        
        // Show playback control view
        self.playbackControlView.isHidden = false
        
        let windowFrame = UIScreen.main.bounds
        
        if (animated) {
            UIView.animate(withDuration: 0.3, delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: { () -> Void in
                    self.topWindow!.frame = windowFrame
                    self.topWindow!.layoutIfNeeded()
                }, completion: { (finished) -> Void in
                    self.topWindow!.frame = windowFrame
                    self.topWindow!.layoutIfNeeded()
            })
        } else {
            self.topWindow!.frame = windowFrame
            self.topWindow!.layoutIfNeeded()
        }
    }
    
    /**
     * This method will be check frame of minimized window
     * If its frame is out of minimizeVisibleArea, we we re-frame it
     */
    func refreshAndCorrectFrameForMinimizedView(_ animated: Bool) {
        if (self.isMinimized && self.topWindow != nil) {
            var windowFrame = self.topWindow!.frame
            
            if (windowFrame.origin.x < self.minimizeVisibleArea.origin.x) {
                windowFrame.origin.x = self.minimizeVisibleArea.origin.x;
            }
            
            if (windowFrame.origin.x + windowFrame.width > self.minimizeVisibleArea.origin.x + self.minimizeVisibleArea.width) {
                windowFrame.origin.x = (self.minimizeVisibleArea.origin.x + self.minimizeVisibleArea.width) - windowFrame.width
            }
            
            if (windowFrame.origin.y < self.minimizeVisibleArea.origin.y) {
                windowFrame.origin.y = self.minimizeVisibleArea.origin.y;
            }
            
            if (windowFrame.origin.y + windowFrame.height > self.minimizeVisibleArea.origin.y + self.minimizeVisibleArea.height) {
                windowFrame.origin.y = (self.minimizeVisibleArea.origin.y + self.minimizeVisibleArea.height) - windowFrame.height
            }
            
            if (animated) {
                UIView.animate(withDuration: 0.3, delay: 0.0,
                    options: UIViewAnimationOptions(),
                    animations: { () -> Void in
                        self.topWindow!.frame = windowFrame
                        self.topWindow!.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        self.topWindow!.frame = windowFrame
                        self.topWindow!.layoutIfNeeded()
                })
            } else {
                self.topWindow!.frame = windowFrame
                self.topWindow!.layoutIfNeeded()
            }
        }
    }
    
    /**
     * Methods support convert time interval to display string
     */
    private func stringFromTimeInterval(_ timeInterval: TimeInterval) -> String {
        let minuteDuration = Int(abs(timeInterval)) / 60;
        let secondDuration = Int(abs(timeInterval)) % 60;
        
        return NSString(format: "%d:%02d", minuteDuration, secondDuration) as String;
    }
    
    @objc func updateAllPlaybackInfoOnUI() {
        if (self.mediaPlayer!.playbackState != MPMoviePlaybackState.interrupted) {
            // Now we can seek to time
            let duration = self.mediaPlayer!.duration;
            let currentPlaybackTime = self.mediaPlayer!.currentPlaybackTime;
            let remainTime = duration - currentPlaybackTime;
            
            if (!self.isDraggingSlider) {
                let percentDone = Float(currentPlaybackTime / duration);
                self.playbackSlider.value = percentDone
            }
            
            // Start time
            self.playbackTimeLabel.text = self.stringFromTimeInterval(currentPlaybackTime);
            self.playbackRemainTimeLabel.text = "-\(self.stringFromTimeInterval(remainTime))";
        } else {
            self.playbackSlider.value = 0;
            self.playbackTimeLabel.text = "0:00";
            self.playbackRemainTimeLabel.text = "0:00";
        }
    }
    
    /**
    * Whe playback started, we will run this timer for update info on UI
    */
    private func startTrackingTimer() {
        if (self.trackingTimer != nil) {
            return
        } else {
            self.trackingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(VideoPlayerView.updateAllPlaybackInfoOnUI), userInfo: nil, repeats: true)
        }
    }
    
    /**
    * When this playback stopped or paused, we will stop timer update UI
    */
    private func stopTrackingTimer() {
        if (self.trackingTimer != nil) {
            self.trackingTimer!.invalidate()
            self.trackingTimer = nil;
        }
    }
    
    func showPlaybackControlView() {
        if (self.showPlaybackControlTimer != nil) {
            self.showPlaybackControlTimer!.invalidate()
            self.showPlaybackControlTimer = nil
        }
        
        // Init timer will hide playback control after 3s
        self.showPlaybackControlTimer = Timer.scheduledTimer(timeInterval: 3.3, target: self, selector: #selector(VideoPlayerView.hidePlaybackControlView), userInfo: nil, repeats: false)
        
        UIView.animate(withDuration: 0.3, delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.playbackControlView.alpha = 1
                self.doneButton.alpha = 1
            }, completion: { (finished) -> Void in
                self.playbackControlView.alpha = 1
                self.doneButton.alpha = 1
        })
    }
    
    @objc func hidePlaybackControlView() {
        if (self.showPlaybackControlTimer != nil) {
            self.showPlaybackControlTimer!.invalidate()
            self.showPlaybackControlTimer = nil
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.playbackControlView.alpha = 0
                self.doneButton.alpha = 0
            }, completion: { (finished) -> Void in
                self.playbackControlView.alpha = 0
                self.doneButton.alpha = 0
        })
    }
    
    // MARK: Support play methods
    
    func playFile(_ filePath: String) {
        // Stop first
        self.stop()
        
        self.mediaPlayer?.contentURL = URL(fileURLWithPath: filePath)
        self.mediaPlayer?.movieSourceType = MPMovieSourceType.file
        
        // Play this file
        self.loadingIndicatorView!.startAnimating()
        self.mediaPlayer?.play()
    }
    
    func playStreamingVideo(_ streamingPath: String) {
        // Stop first
        self.stop()
        
        self.mediaPlayer?.contentURL = URL(string: streamingPath)
        self.mediaPlayer?.movieSourceType = MPMovieSourceType.streaming
        
        // Play this file
        self.loadingIndicatorView!.startAnimating()
        self.mediaPlayer?.play()
    }
    
    // MARK: Player control methods
    
    func play() {
        self.mediaPlayer?.play()
        
        // Update UI and start timer
        self.updateAllPlaybackInfoOnUI()
    }
    
    func pause() {
        self.mediaPlayer?.pause()
    }
    
    func stop() {
        self.mediaPlayer?.stop()
    }
    
    func seekToTime(_ timeInterval: TimeInterval) {
        if (self.mediaPlayer!.playbackState != MPMoviePlaybackState.interrupted) {
            // Now we can seek to time
            self.mediaPlayer!.currentPlaybackTime = timeInterval
            
            self.updateAllPlaybackInfoOnUI();
        }
    }
    
    // MARK: Playback notifications
    
    @objc func applicationWillResignActive(_ notification: Notification?) {
        self.pause()
    }
    
    @objc func playbackDidChangeState(_ notification: Notification?) {
        if ((notification!.object as? MPMoviePlayerController) == self.mediaPlayer) {
            if (self.mediaPlayer!.playbackState == MPMoviePlaybackState.playing) {
                
                // start timer
                self.playButton.isSelected = true;
                self.updateAllPlaybackInfoOnUI()
                self.startTrackingTimer()
                
            } else if (self.mediaPlayer!.playbackState == MPMoviePlaybackState.paused) {
                
                // Stop timer
                self.playButton.isSelected = false;
                self.stopTrackingTimer()
                
            } else if (self.mediaPlayer!.playbackState == MPMoviePlaybackState.stopped) {
                self.playButton.isSelected = false;
                self.playbackSlider.value = 0;
                self.playbackTimeLabel.text = "0:00";
                self.playbackRemainTimeLabel.text = "0:00";
                self.stopTrackingTimer()
            }
            
            // Display playback control
            self.showPlaybackControlView()
        }
    }
    
    @objc func playbackDidChangeLoadingState(_ notification: Notification?) {
        if ((notification!.object as? MPMoviePlayerController) == self.mediaPlayer) {
            let state = self.mediaPlayer!.loadState
            
            // The buffer has enough data that playback can begin, but it may run out of data before playback finishes.
            if (state.rawValue & MPMovieLoadState.playable.rawValue != 0) {
                self.updateAllPlaybackInfoOnUI()
                self.loadingIndicatorView.stopAnimating()
            }
            
            // Enough data has been buffered for playback to continue uninterrupted.
            if (state.rawValue & MPMovieLoadState.playthroughOK.rawValue != 0) {
                self.updateAllPlaybackInfoOnUI()
                self.loadingIndicatorView.stopAnimating()
            }
            
            // The buffering of data has stalled.
            if (state.rawValue & MPMovieLoadState.stalled.rawValue != 0) {
                self.loadingIndicatorView.startAnimating()
            }
            
            // The load state is not known at this time.
            if (state.rawValue & MPMovieLoadState().rawValue != 0) {
                self.loadingIndicatorView.startAnimating()
            }
        }
    }
    
    @objc func playbackDidFinish(_ notification: Notification?) {
        if ((notification!.object as? MPMoviePlayerController) == self.mediaPlayer) {
            
        }
    }
}
