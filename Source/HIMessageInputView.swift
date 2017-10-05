//
//  HIMessageInputView.swift
//  HIChat
//
//  Created by Vlad Getman on 15.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import UIKit
import HalcyonInnovationKit
import DAKeyboardControl

open class HIMessageInputView: UIView {

    open static var Margins = UIEdgeInsetsMake(7, 55, 7, 55)
    open static var TextContainerInset = UIEdgeInsetsMake(5, 8, 5, 8)
    open static var Font = UIFont.systemFont(ofSize: 17)
    
    internal weak var tableView: UITableView?
    internal weak var delegate: HIMessageDelegate?
    
    open fileprivate(set) var textView: HITextView
    open fileprivate(set) var sendButton: UIButton
    open fileprivate(set) var mediaButton: UIButton
    
    open fileprivate(set) var dividerView: UIView
    
    fileprivate var maxHeight: CGFloat = 0
    
    override open var frame: CGRect {
        didSet {
            if let superview = self.superview {
                let height = superview.height
                
                maxHeight = height - (height - (frame).maxY)
                
                self.textView.isScrollEnabled = maxHeight <= frame.height
                
                self.invalidateInsets()
            }
        }
    }
    
    open var enableKeyboardObservers: Bool = false {
        didSet {
            if oldValue != enableKeyboardObservers {
                if let superview = self.superview {
                    if enableKeyboardObservers {
                        superview.addKeyboardPanning(actionHandler: { (rect, opening, closing) in
                            var frame = self.frame
                            frame.origin.y = rect.origin.y - frame.height
                            if #available(iOS 11.0, *) {
                                let inset = self.safeAreaInsets.bottom
                                let maxY = superview.frame.height - inset
                                if frame.maxY >= maxY {
                                    frame.origin.y -= frame.maxY - maxY
                                }
                            }
                            self.frame = frame
                            if opening {
                                self.tableView?.scrollToEnd()
                            }
                        })
                    } else {
                        superview.removeKeyboardControl()
                    }
                }
            }
        }
    }
    
    @available(iOS 11.0, *)
    open override var safeAreaInsets: UIEdgeInsets {
        guard let window = UIApplication.shared.keyWindow else {
            return .zero
        }
        return window.safeAreaInsets
    }
    
    open override var backgroundColor: UIColor? {
        didSet {
            if let view = viewWithTag(13412) {
                view.backgroundColor = backgroundColor
            }
        }
    }
    
    deinit {
        enableKeyboardObservers = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(controller: UIViewController) {
        
        let margins = HIMessageInputView.Margins
        let textContainerInset = HIMessageInputView.TextContainerInset
        
        let height = HIMessageInputView.Font.lineHeight + margins.top + margins.bottom + textContainerInset.top + textContainerInset.bottom
        let width = controller.view.width
        
        var frame = controller.view.frame
        frame.size.height = height
        frame.origin.y = controller.view.height - frame.height
        if #available(iOS 11.0, *) {
            frame.origin.y -= UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        
        mediaButton = UIButton(frame: CGRect(x: 0, y: 0, width: margins.left, height: height))
        mediaButton.setImage(UIImage(named: "hic-camera-button", in: HIChatViewController.bundle(), compatibleWith: nil), for: .normal)
        mediaButton.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        
        sendButton = UIButton(frame: CGRect(x: width - margins.right, y: 0, width: margins.right, height: height))
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        sendButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        
        let sendColor = UIColor.gray
        
        sendButton.setTitleColor(sendColor, for: .normal)
        sendButton.setTitleColor(sendColor.withAlphaComponent(0.5), for: .highlighted)
        sendButton.setTitleColor(UIColor(hex: 0xd2d2d2), for: .disabled)
        sendButton.isEnabled = false
        
        dividerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
        dividerView.backgroundColor = UIColor(hex: 0xadadad)
        dividerView.autoresizingMask = .flexibleWidth
        
        textView = HITextView(frame: CGRect(x: margins.left, y: margins.top, width: width - margins.left - margins.right, height: height - margins.top - margins.bottom))
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = HIMessageInputView.TextContainerInset
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.placeholderTextColor = UIColor(hex: 0xc8c8ce)
        textView.placeholder = "Type your message here..."
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor(hex: 0xfafafa)
        textView.layer.borderColor = UIColor(hex: 0xc7c7cc).cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 4
        textView.clipsToBounds = true
        textView.autoresizingMask = [.flexibleWidth]
        
        super.init(frame: frame)
        
        mediaButton.addTarget(self, action: #selector(mediaTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        textView.delegate = self
        
        autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        
        backgroundColor = UIColor(hex: 0xf9f9f9)
        
        addSubview(dividerView)
        addSubview(mediaButton)
        addSubview(sendButton)
        addSubview(textView)
        
        if #available(iOS 11.0, *) {
            let bottomOffset = safeAreaInsets.bottom
            if bottomOffset > 0 {
                clipsToBounds = false
                let view = UIView(frame: CGRect(x: 0, y: height, width: width, height: bottomOffset))
                view.tag = 13412
                view.backgroundColor = backgroundColor
                view.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
                addSubview(view)
            }
        }
    }
    
    open func invalidateInsets() {
        let offset = superview!.height - frame.minY
        
        var insets = tableView!.contentInset
        insets.bottom = offset
        if #available(iOS 11.0, *) {
            insets.bottom -= safeAreaInsets.bottom
        }
        tableView!.contentInset = insets
        tableView!.scrollIndicatorInsets = insets
    }
    
    open func adjustTextViewSize() {
        
        let marginsHeight = HIMessageInputView.Margins.top + HIMessageInputView.Margins.bottom
        
        let width = textView.width
        
        var newHeight = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        
        if newHeight + marginsHeight > maxHeight {
            newHeight = maxHeight - marginsHeight
        }
        let diff = textView.height - newHeight
        
        var frame = textView.frame
        frame.size.height = newHeight
        textView.frame = frame
        
        frame = self.frame
        frame.size.height = textView.height + marginsHeight
        frame.origin.y += diff
        self.frame = frame
    }
    
    open func invalidateSendButton() {
        let hasText = textView.text.cleanWhitespaces().length > 0
        if let shouldSend = delegate?.inputViewShouldSendMessage?(self) {
            sendButton.isEnabled = shouldSend && hasText
        } else {
            sendButton.isEnabled = hasText
        }
    }
    
    @objc fileprivate func mediaTapped() {
        delegate?.inputViewDidSelectMediaButton(self)
    }
    
    @objc fileprivate func sendTapped() {
        if let shouldSend = delegate?.inputViewShouldSendMessage?(self) {
            if !shouldSend {
                return
            }
        }
        
        let message = textView.text.cleanWhitespaces()
        
        textView.text = ""
        textViewDidChanged()
        
        delegate?.inputView(self, didSendMessage: message)
    }
    
    fileprivate func textViewDidChanged() {
        invalidateSendButton()
        adjustTextViewSize()
    }
}

extension HIMessageInputView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        textViewDidChanged()
    }
}
