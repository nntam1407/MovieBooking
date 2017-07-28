//
//  MaterialRefreshControl.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/28/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

class MaterialRefreshControl: UIRefreshControl {
    
    private var indicatorView: CircleLoadingView?
    private var isAnimating: Bool = false
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init() {
        super.init()
        
        self.setUpRefreshView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setUpRefreshView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpRefreshView()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Hide default indicator view
        self.tintColor = UIColor.clear
        self.tintColorDidChange()
        
        let scrollView = self.superview as? UIScrollView
        
        if (scrollView != nil) {
            // Track content offset changed event
            scrollView!.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
            
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        let scrollView = self.superview as? UIScrollView
        
        if (scrollView != nil) {
            // remove observer
            scrollView!.removeObserver(self, forKeyPath: "contentOffset", context: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.indicatorView != nil) {
            self.indicatorView!.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        }
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        
        // Start custom animated
        self.startRefreshAnimated()
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        self.stopRefreshAnimated()
    }
    
    deinit {
        self.removeTarget(self, action: #selector(MaterialRefreshControl.valueChanged(_:)), for: UIControlEvents.valueChanged)
        
        DLog("Material refresh deinit")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "contentOffset" && !self.isRefreshing) {
            let scrollView = object as? UIScrollView
            
            if (scrollView != nil && scrollView!.isDragging) {
                //                    let newPoint = change?[NSKeyValueChangeNewKey]?.CGPointValue
                let percent = min(1.0, fabs(self.frame.origin.y) / (self.bounds.size.height*3/2))
                
                self.stopRefreshAnimated()
                
                self.indicatorView!.alpha = percent
                self.indicatorView!.value = percent
            }
        }
    }
    
    // MARK: Customize methods
    
    private func setUpRefreshView() {
        // Hide default indicator view
        self.tintColor = UIColor.clear
        self.tintColorDidChange()
        
        // Init indicator view
        self.indicatorView = CircleLoadingView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.indicatorView!.color = UIColor.colorFromHexValue(0x4286F5)
        self.indicatorView!.strokeBehindLayerColor = UIColor.clear
        self.indicatorView!.backgroundColor = UIColor.clear
        self.indicatorView!.strokeWidthPercent = 0.075
        self.indicatorView!.value = 0
        self.indicatorView!.alpha = 0
        self.addSubview(self.indicatorView!)

        // Handle value changed event to start loading animated
        self.addTarget(self, action: #selector(MaterialRefreshControl.valueChanged(_:)), for: UIControlEvents.valueChanged)
    }
    
    private func removeDefaultIndicatorView(_ parentView: UIView) {
        var indicatorView: UIActivityIndicatorView?
        
        for view in parentView.subviews {
            if (view as? UIActivityIndicatorView) != nil {
                indicatorView = view as? UIActivityIndicatorView
            } else {
                self.removeDefaultIndicatorView(view)
            }
         }
        
        indicatorView?.removeFromSuperview()
    }
    
    private func startRefreshAnimated() {
        if (self.isAnimating) {
            return
        }
        
        self.isAnimating = true
        
        self.indicatorView!.alpha = 1.0
        self.indicatorView!.value = 0.8
        self.indicatorView!.startRotateAnimation(1.0, repeatCount: Float.infinity)
    }
    
    private func stopRefreshAnimated() {
        self.isAnimating = false
        self.indicatorView!.stopRotateAnimation()
        self.indicatorView!.value = 0
    }
    
    // MARK: Handle events
    
    @objc func valueChanged(_ refreshControl: MaterialRefreshControl?) {
        self.startRefreshAnimated()
    }
}
