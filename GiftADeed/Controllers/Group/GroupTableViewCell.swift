//
//  GroupTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 2/16/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var collabName: UILabel!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupname: UILabel!
    @IBOutlet weak var groupImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
