//
//  HIMessageTextView.swift
//  HIChat
//
//  Created by Vlad Getman on 30.09.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import UIKit

class HIMessageTextView: UITextView {
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer {
            let targetsIvar = class_getInstanceVariable(UIGestureRecognizer.classForCoder(), "_targets")!
            let targetActionPairs = object_getIvar(gestureRecognizer, targetsIvar)!
            
            for targetActionPair in (targetActionPairs as! NSArray) {
                let pair = String(describing: targetActionPair)
                if pair.contains("loupe") || pair.contains("TextSelection") {
                    return false
                }
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
