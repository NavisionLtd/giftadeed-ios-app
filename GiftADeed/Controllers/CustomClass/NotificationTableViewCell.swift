//
//  NotificationTableViewCell.swift
//  GiftADeed
//
//  Created by nilesh sinha on 10/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var outletMessageLabel: UILabel!
    @IBOutlet weak var outletNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
