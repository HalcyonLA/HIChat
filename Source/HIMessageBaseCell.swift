//
//  HIMessageBaseCell.swift
//  HIChat
//
//  Created by Vlad Getman on 12.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import Foundation
import SDWebImage

open class HIMessageBaseCell: UITableViewCell {
    
    open static var margins = UIEdgeInsetsMake(8, 8, 8, 8)
    open static var avatarMargin = CGFloat(8)
    open static var maxWidth = UIDevice.deviceWidth() - 100
    open static var ballonImageSent = UIImage(named: "hic-bubble-sent", in: HIChatViewController.bundle(), compatibleWith: nil)!.tintColor(UIColor.lightGray)
    open static var ballonImageReceived = UIImage(named: "hic-bubble-received", in: HIChatViewController.bundle(), compatibleWith: nil)!.tintColor(UIColor.blue)
    
    open weak var dataSourse: HIMessageDataSource!
    open weak var delegate: HIMessageDelegate!
    open weak var textFont: UIFont!
    
    fileprivate let containerView: UIView = UIView()
    open let balloonView: UIImageView = UIImageView()
    open fileprivate(set) var avatarView: UIImageView?
    fileprivate var errorButton: UIButton?
    open fileprivate(set) var messageView: UIView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        let demoRect = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        containerView.frame = demoRect
        containerView.backgroundColor = UIColor.clear
        
        messageView = UIView(frame: demoRect)
        messageView.backgroundColor = UIColor.clear
        containerView.addSubview(messageView)
        
        balloonView.frame = demoRect
        balloonView.contentMode = .scaleToFill
        balloonView.backgroundColor = UIColor.clear
        messageView.addSubview(balloonView)
        balloonView.applyFullAutoresizingMask()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        appendGesture(view: messageView)
        
        self.addSubview(containerView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func appendGesture(view: UIView) {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        recognizer.minimumPressDuration = 1
        view.addGestureRecognizer(recognizer)
    }
    
    internal func appendMediaGesture(view: UIView) {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleMediaTapped(_:)))
        view.addGestureRecognizer(recognizer)
    }
    
    open var message: HIMessage! {
        didSet {
            messageDidChanged()
            setNeedsLayout()
        }
    }
    
    open func messageDidChanged() {
        
    }

    open func contentSize() -> CGSize {
        return CGSize.zero
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = self.bounds
        
        if message != nil {
            let margins = HIMessageBaseCell.margins
            
            let fromMe = message.fromMe
            
            balloonView.image = fromMe ? HIMessageBaseCell.ballonImageSent : HIMessageBaseCell.ballonImageReceived
            
            var messageMargin = CGFloat(0)
            let showAvatar = (message.avatarURL != nil || message.avatar != nil) &&
                (dataSourse.avatarsMode() == .both ||
                    (dataSourse.avatarsMode() == .other && !fromMe))
            
            if showAvatar {
                let size = dataSourse.userImageSize!()
                messageMargin += size.width + HIMessageBaseCell.avatarMargin
                if avatarView == nil {
                    avatarView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                    avatarView!.contentMode = .scaleAspectFill
                    avatarView!.clipsToBounds = true
                    avatarView!.layer.cornerRadius = size.height / 2
                    avatarView!.isUserInteractionEnabled = true
                    avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatarTapped(_:))))
                    containerView.addSubview(avatarView!)
                } else {
                    avatarView?.isHidden = false
                }
                
                var frame = avatarView!.frame
                frame.origin.y = self.height - frame.height
                frame.origin.x = !fromMe ? margins.left : (self.width - frame.width - margins.right)
                avatarView!.frame = frame
                
                if let image = message.avatar {
                    avatarView!.image = image
                } else {
                    avatarView?.setImageWithString(message.avatarURL!.absoluteString, activityIndicatorStyle: .gray)
                }
            } else {
                avatarView?.isHidden = true
            }
            
            var messageFrame = messageView.frame
            messageFrame.size = contentSize()
            messageFrame.origin.y = self.height - messageFrame.height - margins.bottom
            if message.fromMe {
                messageFrame.origin.x = self.width - messageFrame.width - messageMargin - margins.right
            } else {
                messageFrame.origin.x = messageMargin + margins.left
            }
            messageView.frame = messageFrame
            
            let isError = message.status == .error
            if isError {
                if errorButton == nil {
                    errorButton = UIButton(type: .infoLight)
                    errorButton!.tintColor = .red
                    errorButton!.addTarget(self, action: #selector(errorTapped), for: .touchUpInside)
                    
                    containerView.addSubview(errorButton!)
                } else {
                    errorButton!.isHidden = false
                }
            } else if !isError && errorButton != nil {
                errorButton!.isHidden = true
            }
            
            if errorButton != nil && !errorButton!.isHidden {
                let x = message.fromMe ? messageView.frame.minX - 25 : messageView.frame.maxX + 25
                errorButton!.center = CGPoint(x: x, y: containerView.height / 2)
            }
        }
    }
    
    @objc fileprivate func handleAvatarTapped(_ sender: UITapGestureRecognizer) {
        delegate.didSelectAvatarInMessageCell(self)
    }
    
    @objc fileprivate func handleMediaTapped(_ sender: UITapGestureRecognizer) {
        delegate.didSelectMediaInMessageCell(self)
    }
    
    @objc fileprivate func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        
        let becomeFirstResponder = delegate.shouldBeCellFirstResponder(self)
        
        if becomeFirstResponder && !self.becomeFirstResponder() {
            return
        }
        
        let menu = UIMenuController.shared
        menu.setTargetRect(messageView.frame, in: containerView)
        if let items = delegate.customMenuItems?(for: self) {
            menu.menuItems = items
        }
        menu.setMenuVisible(true, animated: true)
    }
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(copy(_:)) {
            switch message.type {
            case .text:
                return true
                
            case .photo:
                if message.photo != nil {
                    return true
                } else {
                    return isPhotoSaved()
                }
                
            default:
                return false
            }
        }
        
        if action == #selector(delete(_:)) {
            if message.fromMe {
                if let canDelete = delegate?.canDeleteMessageInCell?(self) {
                    return canDelete
                } else {
                    return true
                }
            } else {
                return false
            }
        }
        
        let selector = NSStringFromSelector(action)
        if message.type != .text && selector.contains("Speak") {
            return false
        }
        
        if action != #selector(cut(_:)) || action != #selector(paste(_:)) {
            if let menu = sender as? UIMenuController {
                if let customItems = delegate.customMenuItems?(for: self) {
                    let titles = customItems.map({ (item) -> String in
                        return item.title
                    })
                    if let items = menu.menuItems {
                        for item in items {
                            if item.action == action && titles.contains(item.title) {
                                return true
                            }
                        }
                    }
                }
            }
            return false
        }
        
        return viewForActions().canPerformAction(action, withSender: sender)
    }
    
    fileprivate func isPhotoSaved() -> Bool {
        if message.type == .photo {
            let key = SDWebImageManager.shared().cacheKey(for: message.photoThumbnailURL)
            return (SDImageCache.shared().imageFromDiskCache(forKey: key) != nil)
        }
        return false
    }
    
    open override func copy(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        switch message.type {
        case .text:
            pasteboard.string = message.messageText!
            
        case .photo:
            if message.photo != nil {
                pasteboard.image = message.photo!
            } else {
                let key = SDWebImageManager.shared().cacheKey(for: message.photoThumbnailURL)
                if let photo = SDImageCache.shared().imageFromDiskCache(forKey: key) {
                    pasteboard.image = photo
                } else {
                    let thumbnailKey = SDWebImageManager.shared().cacheKey(for: message.photoThumbnailURL)
                    if let thumbnailPhoto = SDImageCache.shared().imageFromDiskCache(forKey: thumbnailKey) {
                        pasteboard.image = thumbnailPhoto
                    }
                }
            }
            
        default:
            break
        }
    }
    
    open override func delete(_ sender: Any?) {
        self.delegate.didDeleteMessageInCell(self)
    }
    
    internal func viewForActions() -> UIView {
        return self
    }
    
    @objc fileprivate func errorTapped() {
        let alert = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.delegate.didDeleteMessageInCell(self)
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action) in
            self.delegate.didRetryRequestedMessageInCell(self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.show()
    }
}
