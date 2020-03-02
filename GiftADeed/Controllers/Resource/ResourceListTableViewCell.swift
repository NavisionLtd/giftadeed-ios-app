//
//  ResourceListTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 5/2/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
import  Localize_Swift
class ResourceListTableViewCell: UITableViewCell {

   
    @IBOutlet weak var createdat: UILabel!
    @IBOutlet weak var createdby: UILabel!
    @IBOutlet weak var category: UILabel!
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
