//
//  AudianceTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 2/22/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit

class AudianceTableViewCell: UITableViewCell {

    @IBOutlet weak var chekIcon: UIImageView!
    @IBOutlet weak var groupId: UILabel!
    @IBOutlet weak var groupName: UILabel!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //        self.accessoryType = selected ? .checkmark : .none
    }
    
}
