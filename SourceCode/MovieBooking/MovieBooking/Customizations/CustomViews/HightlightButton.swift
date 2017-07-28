//
//  HightlightButton.swift
//  AskApp
//
//  Created by Tam Nguyen Ngoc on 8/20/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

class HightlightButton: UIButton, CAAnimationDelegate {
    
    private var hightlightLayer: CALayer?

    var hightlightColor: UIColor? = UIColor.black {
        didSet {
            if (self.hightlightLayer != nil) {
                self.hightlightLayer!.backgroundColor = self.hightlightColor?.cgColor
            }
        }
    }
    
    var hightlightLayerOpacity = 0.1;
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initHighlightButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initHighlightButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initHighlightButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.hightlightLayer != nil) {
            var layerRect = self.hightlightLayer!.frame
            layerRect.size.width = self.frame.size.width
            layerRect.size.height = self.frame.size.height
            self.hightlightLayer!.frame = layerRect
            
            self.hightlightLayer!.cornerRadius = self.layer.cornerRadius
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        if (image?.renderingMode != UIImageRenderingMode.alwaysTemplate && state == UIControlState()) {
            super.setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: state)
        } else {
            super.setImage(image, for: state)
        }
    }
    
    func setImage(_ image: UIImage?, forState state: UIControlState, renderTemplateMode renderTemplate: Bool) {
        if (image?.renderingMode != UIImageRenderingMode.alwaysTemplate && state == UIControlState() && renderTemplate) {
            super.setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: state)
        } else {
            super.setImage(image, for: state)
        }
    }
    
    // MARK: Support methods
    
    private func initHighlightButton() {
        if (self.hightlightLayer == nil) {
            self.hightlightLayer = CALayer()
            self.hightlightLayer!.backgroundColor = self.hightlightColor?.cgColor
            
            // Default hide hightlight layer
            self.hightlightLayer!.opacity = 0
            
            self.layer.addSublayer(self.hightlightLayer!)
            self.hightlightLayer!.zPosition = -1
        }
    }
    
    func displayHightlightLayerAnimated() {
        let opacityAniamtion = CABasicAnimation(keyPath: "opacity")
        opacityAniamtion.fromValue = 0
        opacityAniamtion.toValue = self.hightlightLayerOpacity
        
        let groupAnimations = CAAnimationGroup()
        groupAnimations.duration = 0.1
        groupAnimations.isRemovedOnCompletion = false
        groupAnimations.fillMode = kCAFillModeForwards
        groupAnimations.timingFunction = CAMediaTimingFunction(name: "linear")
        groupAnimations.animations = [opacityAniamtion]
        
        self.hightlightLayer?.add(groupAnimations, forKey: "display.animations")
    }
    
    func hideHightlightLayerAnimated() {
        let opacityAniamtion = CABasicAnimation(keyPath: "opacity")
        opacityAniamtion.fromValue = self.hightlightLayerOpacity
        opacityAniamtion.toValue = 0
        
        let groupAnimations = CAAnimationGroup()
        groupAnimations.duration = 0.1
        groupAnimations.isRemovedOnCompletion = true
        groupAnimations.fillMode = kCAFillModeBackwards
        groupAnimations.timingFunction = CAMediaTimingFunction(name: "linear")
        groupAnimations.animations = [opacityAniamtion]
        groupAnimations.delegate = self
        
        self.hightlightLayer?.add(groupAnimations, forKey: nil)
    }
    
    // MARK: Override touch events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Show hightlight layer with animated
        self.displayHightlightLayerAnimated()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // Hide hightlight layer
        Utils.dispatchAfterDelay(0.35, queue: DispatchQueue.main) { () -> Void in
            self.hideHightlightLayerAnimated()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        // Hide layer
        self.hideHightlightLayerAnimated()
    }
    
    // MARK: CAAnimation's delegates
    
    func animationDidStart(_ anim: CAAnimation) {
        self.hightlightLayer?.removeAnimation(forKey: "display.animations")
    }

}
