//
//  HIMessageDelegate.swift
//  HIChat
//
//  Created by Vlad Getman on 15.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import UIKit

@objc public enum HIMessageAvatarsMode : Int {
    case none
    case other
    case both
}

@objc public protocol HIMessageDelegate: HIMessageInputDelegate {
    func didSelectMediaInMessageCell(_ cell: HIMessageBaseCell)
    
    func didSelectAvatarInMessageCell(_ cell: HIMessageBaseCell)
    
    @objc optional func canDeleteMessageInCell(_ cell: HIMessageBaseCell) -> Bool
    
    func didDeleteMessageInCell(_ cell: HIMessageBaseCell)
    
    func didRetryRequestedMessageInCell(_ cell: HIMessageBaseCell)
    
    func shouldBeCellFirstResponder(_ cell: HIMessageBaseCell) -> Bool
    
    @objc optional func customMenuItems(for cell: HIMessageBaseCell) -> [UIMenuItem]?
}

@objc public protocol HIMessageDataSource: NSObjectProtocol {
    
    func messagesArray() -> [HIMessage]
    
    func heightForMessage(_ message: HIMessage) -> CGFloat
    
    @objc optional func configureCell(_ cell: HIMessageBaseCell, forMessage message: HIMessage)
    
    @objc optional func configureHeader(_ header: HIMessageHeaderView, forMessage message: HIMessage)
    
    @objc optional func messageMinWidth(_ fromMe: Bool) -> CGFloat
    
    func mediaMessageWidth() -> CGFloat
    
    func mediaSize(forMessage message: HIMessage) -> CGSize
    
    @objc optional func userImageSize() -> CGSize
    
    func avatarsMode() -> HIMessageAvatarsMode
}
