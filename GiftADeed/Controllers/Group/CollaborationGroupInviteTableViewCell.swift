//
//  CollaborationGroupInviteTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 5/29/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit

class CollaborationGroupInviteTableViewCell: UITableViewCell {

    @IBOutlet weak var userGroupId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var usersGroupName: UILabel!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}
