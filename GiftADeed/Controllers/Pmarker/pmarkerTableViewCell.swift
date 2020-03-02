//
//  pmarkerTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 6/7/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit

class pmarkerTableViewCell: UITableViewCell {

    @IBOutlet weak var subType: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
