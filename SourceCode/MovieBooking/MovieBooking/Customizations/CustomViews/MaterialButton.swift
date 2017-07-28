//
//  MaterialButton.swift
//  AskApp
//
//  Created by Tam Nguyen on 7/21/15.
//  Copyright © 2015 Tam Nguyen. All rights reserved.
//

import UIKit

class MaterialButton: UIButton, CAAnimationDelegate {
    
    // MARK: Properties
    private var hightlightLayer: CALayer?
    
    var enableShadowEffect: Bool = false {
        didSet {
            self.updateShadownEffect()
        }
    }
    
    var shadowColor: UIColor? {
        didSet {
            self.updateShadownEffect()
        }
    }
    
    // MARK: Properties for hightlight effect
    
    var enableHightlightEffect: Bool = false {
        didSet {
            if (self.enableHightlightEffect) {
                if (self.hightlightLayer == nil) {
                    self.hightlightLayer = CALayer()
                    self.hightlightLayer!.backgroundColor = self.hightlightColor?.cgColor
                    
                    // Default hide hightlight layer
                    self.hightlightLayer!.opacity = 0
                    
                    self.layer.addSublayer(self.hightlightLayer!)
                    self.hightlightLayer!.zPosition = -1
                }
            } else {
                self.hightlightLayer?.removeFromSuperlayer()
            }
        }
    }
    
    var hightlightColor: UIColor? = UIColor.gray {
        didSet {
            if (self.hightlightLayer != nil) {
                self.hightlightLayer!.backgroundColor = self.hightlightColor?.cgColor
            }
        }
    }
    
    var hightlightLayerOpacity = 0.15;
    var hightlightEffectScaleFromValue = 0.45

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupCustomizeMaterialButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupCustomizeMaterialButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupCustomizeMaterialButton()
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
        
        // Try to update shadow effect
        self.updateShadownEffect()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        if (image?.renderingMode != UIImageRenderingMode.alwaysTemplate && state == UIControlState()) {
            super.setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: state)
        } else {
            super.setImage(image, for: state)
        }
    }
    
    // MARK: Customization methods
    
    private func setupCustomizeMaterialButton() {
        // Default enable shadow effect
        self.enableShadowEffect = false
        self.enableHightlightEffect = true
        
        // Mask icon with tint color
        self.setImage(self.image(for: UIControlState())?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: UIControlState())
    }
    
    private func updateShadownEffect() {
        if (self.enableShadowEffect) {
            self.layer.shadowOpacity = 0.3
            self.layer.shadowRadius = 3.5
            self.layer.shadowColor = self.shadowColor?.cgColor
            self.layer.shadowOffset = CGSize(width: 1.0, height: 3)
        } else {
            self.layer.shadowOpacity = 0
        }
    }
    
    func displayHightlightLayerAnimated() {
        if (self.hightlightLayer != nil) {
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = self.hightlightEffectScaleFromValue
            scaleAnimation.toValue = 1.0
            
            let opacityAniamtion = CABasicAnimation(keyPath: "opacity")
            opacityAniamtion.fromValue = 0
            opacityAniamtion.toValue = self.hightlightLayerOpacity
            
            let groupAnimations = CAAnimationGroup()
            groupAnimations.duration = 0.1
            groupAnimations.isRemovedOnCompletion = false
            groupAnimations.fillMode = kCAFillModeForwards
            groupAnimations.timingFunction = CAMediaTimingFunction(name: "linear")
            groupAnimations.animations = [scaleAnimation, opacityAniamtion]
            
            self.hightlightLayer!.add(groupAnimations, forKey: "display.animations")
        }
    }
    
    func hideHightlightLayerAnimated() {
        if (self.hightlightLayer != nil) {
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = self.hightlightEffectScaleFromValue
            
            let opacityAniamtion = CABasicAnimation(keyPath: "opacity")
            opacityAniamtion.fromValue = self.hightlightLayerOpacity
            opacityAniamtion.toValue = 0
            
            let groupAnimations = CAAnimationGroup()
            groupAnimations.duration = 0.1
            groupAnimations.isRemovedOnCompletion = true
            groupAnimations.fillMode = kCAFillModeBackwards
            groupAnimations.timingFunction = CAMediaTimingFunction(name: "linear")
            groupAnimations.animations = [scaleAnimation, opacityAniamtion]
            groupAnimations.delegate = self
            
            self.hightlightLayer!.add(groupAnimations, forKey: nil)
        }
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
        Utils.dispatchAfterDelay(0.15, queue: DispatchQueue.main) { () -> Void in
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
