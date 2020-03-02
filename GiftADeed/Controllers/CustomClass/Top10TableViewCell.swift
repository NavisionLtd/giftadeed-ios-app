//
//  Top10TableViewCell.swift
//  GiftADeed
//
//  Created by nilesh sinha on 06/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class Top10TableViewCell: UITableViewCell {

    @IBOutlet weak var outletRankImg: UIImageView!
    @IBOutlet weak var outletNameLabel: UILabel!
    @IBOutlet weak var outletSRNoLabel: UILabel!
    @IBOutlet weak var outletRankLabel: UILabel!
    @IBOutlet weak var outletPointsLabel: UILabel!
    
    @IBOutlet weak var outletScoreLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
