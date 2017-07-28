//
//  AhaActionSheet.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 7/6/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import UIKit

typealias ActionSheetBlock = (_ actionSheet: ActionSheet, _ buttonIndex: Int) -> Void

/**
 Class base support to display action sheet very quickly
 This instance contain a AhaBottomSheetView
 */
class ActionSheet: NSObject, BottomSheetViewDelegate, BottomSheetViewDataSource {
    
    var title: String?
    var buttonTitles = [String]()
    var buttonImageNames = [String]()
    var destructionButtonTitle: String?
    var destructionButtonImageName: String?
    
    /// Handle block when completed
    private var completedBlock: ActionSheetBlock?
    
    /// Private buttomSheetView
    private var bottomSheetView: BottomSheetView?
    
    /// Response index of destruction button if have, else return NSNotFound
    var destructionButtonIndex: Int {
        get {
            if self.destructionButtonTitle != nil {
                return self.buttonTitles.count
            }
            
            return NSNotFound
        }
    }
    
    // MARK:
    // MARK: Override methods
    
    deinit {
        self.completedBlock = nil
        
        DLog("ActionSheet deinit!")
    }
    
    // MARK:
    // MARK: Methods
    
    required init(title: String?,
                  buttonTitles: [String]?,
                  buttonImageNames: [String]?,
                  destructionButtonTitle: String?,
                  destructionButtonImageName: String?) {
        super.init()
        
        self.title = title
        self.buttonTitles = buttonTitles != nil ?  buttonTitles! : [String]()
        self.buttonImageNames = buttonImageNames != nil ?  buttonImageNames! : [String]()
        self.destructionButtonTitle = destructionButtonTitle
        self.destructionButtonImageName = destructionButtonImageName
        
        // Init main buttom sheet
        self.bottomSheetView = BottomSheetView.createNewBottomSheet()
        self.bottomSheetView!.dynamicHeight = true
        self.bottomSheetView!.delegate = self
        self.bottomSheetView!.dataSource = self
        self.bottomSheetView!.userData = self
    }
    
    func showActionSheet(_ animated: Bool, completedBlock completed: ActionSheetBlock?) {
        self.completedBlock = completed
        
        // Show bottom sheet
        if self.bottomSheetView == nil {
            self.bottomSheetView = BottomSheetView.createNewBottomSheet()
            self.bottomSheetView!.dynamicHeight = true
            self.bottomSheetView!.delegate = self
            self.bottomSheetView!.dataSource = self
            self.bottomSheetView!.userData = self
        }
        
        self.bottomSheetView!.showBottomSheet(animated: animated)
    }
    
    func dimissActionSheet(_ animated: Bool) {
        self.completedBlock = nil
        self.bottomSheetView?.hideButtonSheet(animated: animated)
    }
    
    // MARK:
    // MARK: AhaBottomSheet's datasource and delegates
    
    func bottomSheet(displayMode bottomSheet: BottomSheetView) -> BottomSheetDisplayMode {
        return .normal
    }
    
    func bottomSheet(titleOfSheet bottomSheet: BottomSheetView) -> String? {
        return self.title
    }
    
    func bottomSheet(numberOfRow bottomSheet: BottomSheetView) -> NSInteger {
        if self.destructionButtonTitle != nil {
            return self.buttonTitles.count + 1
        }
        
        return self.buttonTitles.count
    }
    
    func bottomSheet(_ bottomSheet: BottomSheetView, heightOfRowAtIndex index: NSInteger) -> CGFloat {
        return kBottomSheetCellDefaultHeight
    }
    
    func bottomSheet(_ bottomSheet: BottomSheetView, configCell cell: BottomSheetTableViewCell, atIndex index: NSInteger) {
        // Config cell data and customize
        
        if self.buttonImageNames.count == 0 && self.destructionButtonImageName == nil {
            cell.mainTitleLabelLeadingConstraint.constant = 15.0
        } else {
            cell.mainTitleLabelLeadingConstraint.constant = 50.0
            cell.iconImageView.contentMode = .center
        }
        
        if index < self.buttonTitles.count {
            cell.mainTitleLabel.textColor = UIColor.black
            cell.mainTitleLabel.text = self.buttonTitles[index]
            
            if index < self.buttonImageNames.count {
                let imageNamed = self.buttonImageNames[index]
                cell.iconImageView.image = UIImage(named: imageNamed)
            } else {
                cell.iconImageView.image = nil
            }
            
        } else if index == self.buttonTitles.count {
            cell.mainTitleLabel.textColor = UIColor.colorFromHexValue(0xEB1E37)
            cell.mainTitleLabel.text = self.destructionButtonTitle
            
            if self.destructionButtonImageName != nil {
                cell.iconImageView.image = UIImage(named: self.destructionButtonImageName!)
            } else {
                cell.iconImageView.image = nil
            }
        }
    }
    
    func bottomSheet(_ bottomSheet: BottomSheetView, didSelectRowAtIndex index: NSInteger) {
        // Call completed block if have
        self.completedBlock?(self, index)
        
        // Hide bottom sheet
        bottomSheet.hideButtonSheet(animated: true)
    }
    
    func bottomSheet(didDismissed bottomSheet: BottomSheetView, animated: Bool) {
        self.bottomSheetView?.userData = nil
        self.bottomSheetView = nil
        self.completedBlock = nil
    }
}
