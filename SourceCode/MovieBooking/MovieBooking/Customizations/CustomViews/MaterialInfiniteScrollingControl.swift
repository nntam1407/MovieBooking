//
//  MaterialInfiniteScrollingControl.swift
//  AskApp
//
//  Created by Tam Nguyen on 8/7/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

let kInfiniteScrollingControlHeight: CGFloat = 60

class MaterialInfiniteScrollingControl: UIControl {
    
    // MARK: Properties
    
    private var originalBottomInset: CGFloat = 0
    
    private var loadingView: MaterialIndicatorView?
    
    var isLoading: Bool = false
    var canLoading: Bool = true
    
    // MARK: Override methods
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: kInfiniteScrollingControlHeight))
        
        // Should call setupInfiniteScrolling methods
        self.setupInfiniteScrolling()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        let scrollView = self.superview as? UIScrollView
        
        if (scrollView != nil) {
            // remove observer
            scrollView!.removeObserver(self, forKeyPath: "contentOffset", context: nil)
            scrollView!.removeObserver(self, forKeyPath: "contentSize", context: nil)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let scrollView = self.superview as? UIScrollView
        
        if (scrollView != nil) {
            self.originalBottomInset = scrollView!.contentInset.bottom
            
            // Track content offset changed event
            scrollView!.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
            
            scrollView!.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.loadingView != nil) {
            self.loadingView!.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "contentOffset") {
            let scrollView = object as? UIScrollView
            let newPoint = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgPointValue
            
            if scrollView != nil && newPoint != nil {
                if ((newPoint!.y + scrollView!.bounds.size.height) >= scrollView!.contentSize.height && scrollView!.contentSize.height > scrollView!.bounds.size.height) {
                    self.beginInfiniteLoading()
                }
            }
        } else if (keyPath == "contentSize") {
            let newSize = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgSizeValue
            
            if newSize != nil {
                self.frame = CGRect(x: 0, y: newSize!.height, width: self.frame.width, height: self.frame.height)
            }
        }
    }
    
    // MARK: Private methods
    
    private func setupInfiniteScrolling() {
        self.backgroundColor = UIColor.clear
        self.isHidden = true
        
        // Init indicator view
        self.loadingView = MaterialIndicatorView(frame: CGRect(x: self.frame.width/2, y: self.frame.height/2, width: 24, height: 24))
        self.loadingView!.autoresizingMask = UIViewAutoresizing()
        self.addSubview(self.loadingView!)
    }
    
    // MARK: Public methods
    
    func beginInfiniteLoading() {
        let scrollView = self.superview as? UIScrollView
        
        if (scrollView == nil || self.isLoading || !self.canLoading) {
            return
        }
        
        // Start loading
        self.isLoading = true
        
        // Update content inset of this table view, then add self at bottom of table view
        var contentInset = scrollView!.contentInset
        contentInset.bottom += self.frame.height
        scrollView!.contentInset = contentInset
        
        var frame = self.frame
        frame.origin.x = 0
        frame.origin.y = scrollView!.contentSize.height
        frame.size.width = scrollView!.bounds.size.width;
        self.frame = frame
        
        // Start animating
        self.isHidden = false
        self.loadingView!.startAnimating()
        
        // Call trigger method
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.sendActions(for: UIControlEvents.valueChanged)
        }
    }
    
    func endInfiniteLoading() {
        let scrollView = self.superview as? UIScrollView
        
        if (scrollView == nil || !self.isLoading) {
            return
        }
        
        // Stop animating
        self.loadingView!.stopAnimating()
        self.isHidden = true
        
        // Reset content inset
        var contentInset = scrollView!.contentInset
        contentInset.bottom -= self.frame.height

        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            
            scrollView!.contentInset = contentInset
            
            }) { (finished) -> Void in
                self.isLoading = false
        }
    }
}
