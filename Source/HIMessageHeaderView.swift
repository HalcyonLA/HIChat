//
//  HIMessageHeaderView.swift
//  HIChat
//
//  Created by Vlad Getman on 19.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import UIKit

open class HIMessageHeaderView: UITableViewHeaderFooterView {
    
    open static var customFont: UIFont?
    
    let label: UILabel
    
    override init(reuseIdentifier: String?) {
        label = UILabel()
        label.textColor = UIColor(hex: 0xc8c7cc)
        if let font = HIMessageHeaderView.customFont {
            label.font = font
        } else {
            label.font = UIFont.systemFont(ofSize: 10)
        }
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.addSubview(label)
        self.contentView.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var frame = self.bounds
        frame.origin.x = 15
        frame.size.width -= 30
        label.frame = frame
    }
}
