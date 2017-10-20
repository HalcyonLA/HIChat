//
//  HIRequestedMessage.swift
//  HIChat
//
//  Created by Vlad Getman on 30.09.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import UIKit
import HalcyonInnovationKit
import SDWebImage

@objc public protocol HIRequestedMessageDelegate: NSObjectProtocol {
    func messageRequestDidStarted(_ message: HIRequestedMessage)
    func messageRequest(_ message: HIRequestedMessage, didFinishWithError error: NSError?)
    @objc optional func messageRequest(for message: HIRequestedMessage, completion: @escaping ((_ message: Any?, _ error: NSError?) -> Void)) -> DataManagerRequest
    @objc optional func startCustomRequest(for message: HIRequestedMessage, completion: @escaping ((_ message: Any?, _ error: NSError?) -> Void)) -> Bool
}

open class HIRequestedMessage: NSObject {
    
    open weak var delegate: HIRequestedMessageDelegate?
    
    open let chatId: String
    open var text: String?
    open var image: UIImage? {
        didSet {
            if image != nil && (image!.size.height > 1080 || image!.size.width > 1080) {
                image = image!.scaledToFitSize(CGSize(width: 1080, height: 1080))
            }
        }
    }
    
    open var message: Any?
    
    fileprivate let messageId: Int
    fileprivate var createdAt: Date = Date()
    fileprivate var msgStatus: HIMessageStatus = .none
    fileprivate var request: DataManagerRequest?
    
    public init(chatId: String) {
        self.messageId = HIRequestedMessageStorage.shared.requestedIndex()
        self.chatId = chatId
        super.init()
    }
    
    open func sendRequest() {
        guard let delegate = self.delegate else {
            assert(false, "Can't send without delegate")
            return
        }
        
        let shouldStart = msgStatus == .none
        msgStatus = .requested
        
        if shouldStart {
            delegate.messageRequestDidStarted(self)
            HIRequestedMessageStorage.shared.addMessage(self)
        }
        let completion: ((_ message: Any?, _ error: NSError?) -> Void) = { (msg, error) in
            if error != nil {
                self.msgStatus = .error
            } else {
                self.msgStatus = .sent
                self.message = msg
                HIRequestedMessageStorage.shared.removeMessage(self)
            }
            self.delegate?.messageRequest(self, didFinishWithError: error)
        }
        
        var customRequest: Bool = false
        if let custom = delegate.startCustomRequest?(for: self, completion: completion) {
            customRequest = custom
        }
        
        guard !customRequest, let request = delegate.messageRequest?(for: self, completion: completion) else {
            return
        }
        
        self.request = request
    }
    
    open func cancelRequest() {
        request?.cancel()
    }
}

extension HIRequestedMessage: HIMessage {
    public var identifier: String {
        return "requested_\(messageId)"
    }

    public var type: HIMessageType {
        if photo != nil {
            return .photo
        }
        return .text
    }
    
    public var messageText: String? {
        return text
    }
    
    public var avatar: UIImage? {
        return nil
    }
    
    public var avatarURL: URL? {
        return nil
    }
    
    public var photoThumbnailURL: URL? {
        return nil
    }
    
    public var photoURL: URL? {
        return nil
    }
    
    public var photo: UIImage? {
        return image
    }
    
    public var fromMe: Bool {
        return true
    }
    
    public var date: Date {
        return createdAt
    }
    
    public var status: HIMessageStatus {
        return self.msgStatus
    }
    
    public var readed: Bool {
        return true
    }
    
    public var userName: String? {
        return nil
    }
}


open class HIRequestedMessageStorage: NSObject {
    open static let shared = HIRequestedMessageStorage()
    private var _requestedIndex: Int = 0
    fileprivate var messages: [HIRequestedMessage] = []
    
    fileprivate func requestedIndex() -> Int {
        _requestedIndex += 1
        return _requestedIndex
    }
    
    open func messagesForChatId(_ chatId: String) -> [HIRequestedMessage] {
        let filtered = messages.filter { (message) -> Bool in
            return message.chatId == chatId
        }
        return filtered
    }
    
    fileprivate func addMessage(_ message: HIRequestedMessage) {
        messages.append(message)
    }
    
    open func removeMessage(_ message: HIRequestedMessage) {
        if let index = messages.index(of: message) {
            messages.remove(at: index)
        }
    }
}
