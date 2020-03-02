//
//  TableViewHeaderLabel.swift
//  GiftADeed
//
//  Created by nilesh sinha on 30/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class TableViewHeaderLabel: UILabel {

    var topInset:       CGFloat = 0
    var rightInset:     CGFloat = 12
    var bottomInset:    CGFloat = 0
    var leftInset:      CGFloat = 12
    
    override func drawText(in rect: CGRect) {
        
        let insets: UIEdgeInsets = UIEdgeInsets(top: self.topInset, left: self.leftInset, bottom: self.bottomInset, right: self.rightInset)
        self.setNeedsLayout()
        
        self.textColor = UIColor.white
        self.backgroundColor = UIColor.black
        
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
        
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
