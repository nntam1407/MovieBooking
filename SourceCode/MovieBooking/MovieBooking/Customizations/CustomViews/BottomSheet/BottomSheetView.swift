//
//  AhaBottomSheetView.swift
//  Ahacho Business
//
//  Created by Tam Nguyen on 4/29/16.
//  Copyright © 2016 Tam Nguyen. All rights reserved.
//

import UIKit

@objc enum BottomSheetDisplayMode: Int {
    case normal = 0
    case loadingData = 1
}

let kAhaBottomSheetDefaultHeight: CGFloat = 300.0

@objc protocol BottomSheetViewDataSource {
    
    /// Return mode to display
    @objc optional func bottomSheet(displayMode bottomSheet: BottomSheetView) -> BottomSheetDisplayMode
    
    /// Default titleView: Set title for bottom sheet. Nil mean has no default title
    @objc optional func bottomSheet(titleOfSheet bottomSheet: BottomSheetView) -> String?
    
    /// nil mean don't display right button
    @objc optional func bottomSheet(titleOfRightButtonOnHeader bottomSheet: BottomSheetView) -> String?
    
    /// Set number of item in sheet
    @objc optional func bottomSheet(numberOfRow bottomSheet: BottomSheetView) -> NSInteger
    
    /// Set height of row
    @objc optional func bottomSheet(_ bottomSheet: BottomSheetView, heightOfRowAtIndex index: NSInteger) -> CGFloat
    
    /// Config cell before it will be displayed
    @objc optional func bottomSheet(_ bottomSheet: BottomSheetView, configCell cell: BottomSheetTableViewCell, atIndex index: NSInteger)
    
    /// Calling when have no data to display. Nil mean don't display this
    @objc optional func bottomSheet(noDisplayDataPlaceholder bottomSheet: BottomSheetView) -> String?
    
    /// Config no data display label UI
    @objc optional func bottomSheet(_ bottomSheet: BottomSheetView, configNoDisplayDataPlaceholderLabel label: UILabel)
}

@objc protocol BottomSheetViewDelegate {
    @objc optional func bottomSheet(_ bottomSheet: BottomSheetView, didSelectRowAtIndex index: NSInteger)
    @objc optional func bottomSheet(didTouchOnTopRightButton bottomSheet: BottomSheetView)
    
    /// For present events
    @objc optional func bottomSheet(willPresented bottomSheet: BottomSheetView, animated: Bool)
    @objc optional func bottomSheet(didPresented bottomSheet: BottomSheetView, animated: Bool)
    
    /// For dismiss view
    @objc optional func bottomSheet(willDismissed bottomSheet: BottomSheetView, animated: Bool)
    @objc optional func bottomSheet(didDismissed bottomSheet: BottomSheetView, animated: Bool)
}

class BottomSheetView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    /// Addition tag value
    var additionTag: Int = 0
    
    /// Addition data to tag in this bottom sheet
    var userData: AnyObject?
    
    @IBOutlet weak var overlayView: UIControl!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noDataPlaceholderLabel: UILabel!
    
    @IBOutlet weak var topTitleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButtonLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var topTitleViewHeightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    // For loading view
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicatorView: MaterialIndicatorView!
    
    /// true if want to make height of this bottomSheet bound of content
    var dynamicHeight = false
    
    weak var dataSource: BottomSheetViewDataSource?
    weak var delegate: BottomSheetViewDelegate?
    
    /// Save display mode status
    private var displayMode: BottomSheetDisplayMode = .normal
    
    /// Support display bottom view below of main table view
    var bottomCustomView: UIView? {
        willSet {
            if self.bottomCustomView != nil {
                self.bottomCustomView!.removeFromSuperview()
            }
        }
        didSet {
            // Add this view into main bottom view
            if self.bottomCustomView != nil {
                var bottomFrame = self.bottomCustomView!.frame
                bottomFrame.size.width = self.bottomView.bounds.width
                bottomFrame.origin.x = 0
                bottomFrame.origin.y = 0
                self.bottomCustomView!.frame = bottomFrame
                
                // Set height for bottom view is equal with bottom custome view
                self.bottomViewHeightConstraint.constant = bottomFrame.height
                
                // Add custom bottom view into bottom view
                self.bottomView.addSubview(self.bottomCustomView!)
                
                let leadingConstraint = NSLayoutConstraint(item: self.bottomCustomView!, attribute: .leading, relatedBy: .equal, toItem: self.bottomView, attribute: .leading, multiplier: 1.0, constant: 0.0)
                
                let trailingConstraint = NSLayoutConstraint(item: self.bottomCustomView!, attribute: .trailing, relatedBy: .equal, toItem: self.bottomView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
                
                let topConstraint = NSLayoutConstraint(item: self.bottomCustomView!, attribute: .top, relatedBy: .equal, toItem: self.bottomView, attribute: .top, multiplier: 1.0, constant: 0.0)
                
                let bottomConstraint = NSLayoutConstraint(item: self.bottomCustomView!, attribute: .bottom, relatedBy: .equal, toItem: self.bottomView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
                
                self.bottomView!.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
            } else {
                self.bottomViewHeightConstraint.constant = 0
            }
            
            // Finally, relayout view
            self.mainView.layoutIfNeeded()
        }
    }
    
    // Some config properties
    
    /// This view will displayed on this window
    var displayWindow: UIWindow?
    
    // Variable for pan gesture
    let animatedDurationTime: CGFloat = 0.3
    let overlayOpacity: Float = 0.5

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK: Class methods
    
    class func createNewBottomSheet() -> BottomSheetView {
        let view = Utils.loadView("AhaBottomSheetView") as? BottomSheetView
        return view!
    }
    
    // MARK: Override methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mainView.layer.masksToBounds = false
        self.mainView.layer.shadowColor = UIColor.black.cgColor
        self.mainView.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.mainView.layer.shadowOpacity = 0.3
        self.mainView.layer.shadowRadius = 2.0
        
        // Hide when stop
        self.loadingIndicatorView.hideWhenStop = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Need layout subview in here
    }
    
    // MARK: Events
    
    @IBAction func didTouchOnOverlayView(_ sender: AnyObject) {
        self.hideButtonSheet(animated: true)
    }
    
    @IBAction func didTouchOnRightButton(_ sender: AnyObject) {
        self.delegate?.bottomSheet?(didTouchOnTopRightButton: self)
    }
    
    // MARK: Public methods
    
    func reloadData() {
        if let displayMode = self.dataSource?.bottomSheet?(displayMode: self) {
            self.displayMode = displayMode
        } else {
            self.displayMode = .normal
        }
        
        if self.displayMode == .loadingData {
            self.topTitleView.isHidden = true
            self.mainTableView.isHidden = true
            self.bottomView.isHidden = true
            self.noDataPlaceholderLabel.isHidden = true
            
            self.loadingView.isHidden = false
            self.loadingIndicatorView.startAnimating()
            
            // Don't need to config title, table view
            return
        } else {
            self.loadingView.isHidden = true
            self.loadingIndicatorView.stopAnimating()
            
            self.topTitleView.isHidden = false
            self.mainTableView.isHidden = false
            self.bottomView.isHidden = false
        }
        
        // Set title label
        let titleText = self.dataSource?.bottomSheet?(titleOfSheet: self)
        
        if titleText == nil || titleText!.characters.count == 0 {
            // Hide title
            self.topTitleView.isHidden = true
            self.topTitleViewHeightContraint.constant = 0
        } else {
            self.topTitleView.isHidden = false
            self.topTitleViewHeightContraint.constant = 32
            
            self.titleLabel.text = titleText
            
            // Set right button if have
            let rightButtonTitle = self.dataSource?.bottomSheet?(titleOfRightButtonOnHeader: self)
            
            if rightButtonTitle == nil || rightButtonTitle!.characters.count == 0 {
                self.rightButton.isHidden = true
                self.rightButtonLabel.isHidden = true
            } else {
                self.rightButton.isHidden = false
                self.rightButtonLabel.isHidden = false
                self.rightButtonLabel.text = rightButtonTitle
            }
        }
        
        // Reload table view
        self.mainTableView.reloadData()
        
        // If no cell is visible, display no data to display label
        if self.displayMode == .normal && self.mainTableView.numberOfRows(inSection: 0) == 0 {
            let displayText = self.dataSource?.bottomSheet?(noDisplayDataPlaceholder: self)
            
            if displayText != nil {
                self.noDataPlaceholderLabel.text = displayText
                self.noDataPlaceholderLabel.isHidden = false
                
                // Call datasource config UI for label
                self.dataSource?.bottomSheet?(self, configNoDisplayDataPlaceholderLabel: self.noDataPlaceholderLabel)
            } else {
                self.noDataPlaceholderLabel.text = nil
                self.noDataPlaceholderLabel.isHidden = false
            }
        }
        
        // Dynamic hieght of main view
        if self.dynamicHeight {
            self.mainViewHeightConstraint.constant = self.topTitleViewHeightContraint.constant + self.mainTableView.contentSize.height + self.bottomViewHeightConstraint.constant
        } else {
            self.mainViewHeightConstraint.constant = kAhaBottomSheetDefaultHeight
        }
        
        // Finally, relayout main view
        self.mainView.layoutIfNeeded()
    }
    
    func showBottomSheet(animated: Bool) {
        // First should get key window
        let keyWindow = APP_DELEGATE.window
        
        if (keyWindow == nil) {
            return
        }
        
        var frame = keyWindow!.frame
        frame.origin.x = 0
        frame.origin.y = 0
        self.frame = frame
        self.layoutIfNeeded()
        
        // Now check and create new windows
        if (self.displayWindow == nil) {
            self.displayWindow = UIWindow(frame: frame)
            self.displayWindow!.addSubview(self)
            
            // Default for first time this view
            self.mainViewBottomConstraint.constant = -self.mainView.bounds.size.height
            self.overlayView.layer.opacity = 0
            self.layoutIfNeeded()
        }
        
        self.displayWindow!.bringSubview(toFront: self)
        
        // Display window
        self.displayWindow!.windowLevel = UIWindowLevelStatusBar + 1
        self.displayWindow!.makeKeyAndVisible()
        
        // Call delegate
        self.delegate?.bottomSheet?(willPresented: self, animated: animated)
        
        if (animated) {
            UIView.animate(withDuration: TimeInterval(self.animatedDurationTime),
                                       delay: 0.0,
                                       options: UIViewAnimationOptions(),
                                       animations: {
                                        
                                        self.mainViewBottomConstraint.constant = 0
                                        self.layoutIfNeeded()
                                        self.overlayView.layer.opacity = self.overlayOpacity
                                        
                }, completion: { (finished) in
                    self.layoutIfNeeded()
                    self.overlayView.layer.opacity = self.overlayOpacity
                    
                    // Call delegate
                    self.delegate?.bottomSheet?(didPresented: self, animated: animated)
            })
        } else {
            self.mainViewBottomConstraint.constant = 0
            self.layoutIfNeeded()
            self.overlayView.layer.opacity = self.overlayOpacity
            
            // Call delegate
            self.delegate?.bottomSheet?(didPresented: self, animated: animated)
        }
        
        // Should refresh data
        self.reloadData()
    }
    
    func hideButtonSheet(animated: Bool) {
        // Call delegate
        self.delegate?.bottomSheet?(willDismissed: self, animated: animated)
        
        if (animated) {
            UIView.animate(withDuration: TimeInterval(self.animatedDurationTime),
                                       delay: 0.0,
                                       options: UIViewAnimationOptions(),
                                       animations: {
                                        
                                        self.mainViewBottomConstraint.constant = -self.mainView.bounds.size.width
                                        self.layoutIfNeeded()
                                        self.overlayView.alpha = 0
                                        
                }, completion: { (finished) in
                    self.layoutIfNeeded()
                    self.displayWindow?.resignKey()
                    self.displayWindow?.windowLevel = APP_DELEGATE.window!.windowLevel - 1
                    
                    // Call delegate
                    self.delegate?.bottomSheet?(didDismissed: self, animated: animated)
            })
        } else {
            self.mainViewBottomConstraint.constant = -self.mainView.bounds.size.width
            self.layoutIfNeeded()
            self.displayWindow?.resignKey()
            self.displayWindow?.windowLevel = APP_DELEGATE.window!.windowLevel - 1
            
            // Call delegate
            self.delegate?.bottomSheet?(didDismissed: self, animated: animated)
        }
    }
    
    func cellForRowAtIndex(_ index: Int) -> BottomSheetTableViewCell? {
        let cell = self.mainTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? BottomSheetTableViewCell
        
        return cell
    }
    
    /**
        Method return index of cell
        - Return NSNotFound if doesn't found index of cell
    */
    func indexForCell(_ cell: BottomSheetTableViewCell) -> Int {
        let indexPath = self.mainTableView.indexPath(for: cell)
        
        if indexPath != nil {
            return (indexPath! as NSIndexPath).row
        }
        
        return NSNotFound
    }
    
    // MARK: UITableView's datasource and delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.displayMode == .loadingData {
            return 0
        }
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.displayMode == .loadingData {
            return 0
        }
        
        if let numberOfRow = self.dataSource?.bottomSheet?(numberOfRow: self) {
            return numberOfRow
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.dataSource?.bottomSheet?(self, heightOfRowAtIndex: (indexPath as NSIndexPath).row) {
            return height
        }
        
        return kBottomSheetCellDefaultHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "BottomSheetTableViewCell") as? BottomSheetTableViewCell
        
        if cell == nil {
            cell = Utils.loadView("BottomSheetTableViewCell") as? BottomSheetTableViewCell
        }
        
        // Call datasource config cell
        self.dataSource?.bottomSheet?(self, configCell: cell!, atIndex: (indexPath as NSIndexPath).row)
        
        // Return cell
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Call delegate
        self.delegate?.bottomSheet?(self, didSelectRowAtIndex: (indexPath as NSIndexPath).row)
    }
}
