//
//  SettingTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 4/29/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
//1. delegate method
protocol CellNotificationSubclassDelegate: class {
    func selectedGroup(name: String,id: String,settingBtn:UISwitch,cell:SettingTableViewCell)
}
class SettingTableViewCell: UITableViewCell {
 weak var delegate: CellNotificationSubclassDelegate?
    @IBOutlet weak var gropId: UILabel!
    @IBOutlet weak var settingBtn: UISwitch!
    @IBOutlet weak var settingName: UILabel!
  
    
    @IBOutlet weak var notificationViewToggle: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    @IBAction func gropSettingBtnPress(_ sender: UISwitch) {
        self.delegate?.selectedGroup(name: settingName.text!, id: gropId.text!, settingBtn: sender, cell: self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
        // Configure the view for the selected state
    }

}
