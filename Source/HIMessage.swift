//
//  HIMessage.swift
//  HIChat
//
//  Created by Vlad Getman on 12.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import Foundation
import UIKit

@objc public enum HIMessageType : Int {
    case text
    case photo
    case custom
}

@objc public enum HIMessageStatus : Int {
    case none
    case requested
    case sent
    case error
}

@objc public protocol HIMessage: NSObjectProtocol {
    
    var type: HIMessageType { get }
    
    var messageText: String? { get }
    
    var avatarURL: URL? { get }
    
    var avatar: UIImage? { get }
    
    var photoThumbnailURL: URL? { get }
    
    var photoURL: URL? { get }
    
    var photo: UIImage? { get }
    
    var fromMe: Bool { get }
    
    var date: Date { get }
    
    var status: HIMessageStatus { get }
    
    var readed: Bool { get }
    
    var identifier: String { get }
}
