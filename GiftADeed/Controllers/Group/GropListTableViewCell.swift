//
//  GropListTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 2/16/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit

class GropListTableViewCell: UITableViewCell {

    @IBOutlet weak var groupNameTxt: UILabel!
    @IBOutlet weak var groupImg: UIImageView!
    @IBOutlet weak var groupListcellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        groupListcellView.layer.cornerRadius = 5
//        groupListcellView.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
