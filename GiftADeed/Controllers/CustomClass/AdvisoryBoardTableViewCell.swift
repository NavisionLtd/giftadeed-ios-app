//
//  AdvisoryBoardTableViewCell.swift
//  GiftADeed
//
//  Created by nilesh sinha on 09/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit

class AdvisoryBoardTableViewCell: UITableViewCell {

    @IBOutlet weak var outletImgUrl: UIImageView!
    @IBOutlet weak var outletName: UILabel!
    @IBOutlet weak var outletDesig: UILabel!
    @IBOutlet weak var outletDesc: UILabel!
    
    @IBOutlet var twiterAction: UIButton!
    @IBOutlet var googlePlusAction: UIButton!
    @IBOutlet var facebookAction: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
