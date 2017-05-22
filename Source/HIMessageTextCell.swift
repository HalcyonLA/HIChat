//
//  HIMessageTextCell.swift
//  HIChat
//
//  Created by Vlad Getman on 12.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import Foundation
import UIKit

open class HIMessageTextCell: HIMessageBaseCell {
    
    let textView: HIMessageTextView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        textView = HIMessageTextView()
        textView.textContainer.lineFragmentPadding = 0
        textView.isEditable = false
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.white
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = .all
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textView.frame = messageView.bounds
        textView.applyFullAutoresizingMask()
        
        messageView.addSubview(textView)
        
        appendGesture(view: textView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var textFont: UIFont! {
        didSet {
            textView.font = textFont
        }
    }
    
    open override func messageDidChanged() {
        let fromMe = message.fromMe
        
        textView.textContainerInset = UIEdgeInsetsMake(8, fromMe ? 10 : 15, 8, fromMe ? 15 : 10)
        
        textView.text = message.messageText
    }
    
    open override func contentSize() -> CGSize {
        return textView.sizeThatFits(CGSize(width: HIMessageBaseCell.maxWidth, height: CGFloat.greatestFiniteMagnitude))
    }
    
    override func viewForActions() -> UIView {
        return textView
    }
}
