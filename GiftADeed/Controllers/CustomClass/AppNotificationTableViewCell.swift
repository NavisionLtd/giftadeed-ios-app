//
//  AppNotificationTableViewCell.swift
//  GiftADeed
//
//  Created by KTS  on 10/07/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit

class AppNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
