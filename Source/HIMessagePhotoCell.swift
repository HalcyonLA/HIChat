//
//  HIMessagePhotoCell.swift
//  HIChat
//
//  Created by Vlad Getman on 12.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import Foundation
import UIKit

open class HIMessagePhotoCell: HIMessageBaseCell {
    
    let photoView: UIImageView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        photoView = UIImageView()
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFill
        photoView.isUserInteractionEnabled = true
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        photoView.frame = messageView.bounds
        photoView.applyFullAutoresizingMask()
        
        messageView.addSubview(photoView)
        
        appendGesture(view: photoView)
        appendMediaGesture(view: photoView)
        
        balloonView.isHidden = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func invalidateMask() {
        let imageView = UIImageView(image: balloonView.image)
        imageView.frame = balloonView.frame
        
        let layer = imageView.layer
        layer.frame = balloonView.bounds
        photoView.layer.mask = layer
        photoView.setNeedsDisplay()
    }
    
    open override func messageDidChanged() {
        nameInsets.left = fromMe ? 10 : 15
        nameInsets.right = fromMe ? 15 : 10
        
        if let photo = message.photo {
            photoView.image = photo
        } else if let url = message.photoThumbnailURL {
            photoView.setImageWithString(url.absoluteString, activityIndicatorStyle: .gray)
        }
        invalidateMask()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        invalidateMask()
    }
    
    open override func contentSize() -> CGSize {
        let size = dataSourse.mediaSize(forMessage: message)
        if size == .zero {
            let mediaSize = dataSourse.mediaMessageWidth()
            return CGSize(width: mediaSize, height: mediaSize)
        }
        return size
    }
}
