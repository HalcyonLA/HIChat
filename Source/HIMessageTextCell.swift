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
    
    let _textView: HIMessageTextView
    
    open var textView: UITextView {
        return _textView
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        _textView = HIMessageTextView()
        _textView.textContainer.lineFragmentPadding = 0
        _textView.isEditable = false
        _textView.backgroundColor = UIColor.clear
        _textView.textColor = UIColor.white
        _textView.isScrollEnabled = false
        _textView.dataDetectorTypes = .all
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        _textView.frame = messageView.bounds
        _textView.applyFullAutoresizingMask()
        
        messageView.addSubview(_textView)
        
        appendGesture(view: _textView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var textFont: UIFont! {
        didSet {
            _textView.font = textFont
        }
    }
    
    open override func messageDidChanged() {
        let fromMe = message.fromMe
        
        let leftSpacing: CGFloat = fromMe ? 10 : 15
        let rightSpacing: CGFloat = fromMe ? 15 : 10
        
        _textView.textContainerInset = UIEdgeInsetsMake(8, leftSpacing, 8, rightSpacing)
        
        nameInsets.left = leftSpacing
        nameInsets.right = rightSpacing
        
        _textView.text = message.messageText
    }
    
    open override func contentSize() -> CGSize {
        return _textView.sizeThatFits(CGSize(width: HIMessageBaseCell.maxWidth, height: CGFloat.greatestFiniteMagnitude))
    }
    
    override func viewForActions() -> UIView {
        return _textView
    }
}
