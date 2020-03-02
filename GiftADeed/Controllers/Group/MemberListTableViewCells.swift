//
//  MemberListTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 2/19/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
protocol customAction : class {
    func didPressMoreOptionsButton(sender:UIButton,memberids: String,memberRoles:String)
}
class MemberListTableViewCells: UITableViewCell {
    var cellDelegate: customAction?
    @IBOutlet weak var dotMenuBtn: UIButton!
    @IBOutlet weak var memberRole: UITextField!
    @IBOutlet weak var memberEmail: UILabel!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func dotMenuPress(_ sender: UIButton) {
        cellDelegate?.didPressMoreOptionsButton(sender: self.dotMenuBtn, memberids: memberId.text!, memberRoles: memberRole.text!)
    }
}
