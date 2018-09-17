//
//  HITextView.swift
//  HIChat
//
//  Created by Vlad Getman on 30.09.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import UIKit
import SZTextView

open class HITextView: SZTextView {

    public weak var overrideNextResponder: UIResponder? {
        didSet {
            if overrideNextResponder != nil {
                NotificationCenter.default.addObserver(self, selector: #selector(menuDidHide), name: UIMenuController.didHideMenuNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self, name: UIMenuController.didHideMenuNotification, object: nil)
            }
        }
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if overrideNextResponder != nil {
            return false
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    open override var next: UIResponder? {
        if overrideNextResponder != nil {
            return overrideNextResponder
        } else {
            return super.next
        }
    }
    
    @objc fileprivate func menuDidHide() {
        overrideNextResponder = nil
    }
}

