//
//  CollaborationMemberListTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 5/30/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
protocol CellRemoveSubclassDelegate: class {
    func deleteButtonTapped(name: String)
}
class CollaborationMemberListTableViewCell: UITableViewCell {
  weak var delegate: CellRemoveSubclassDelegate?
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var memberRole: UILabel!
    @IBOutlet weak var memberImg: UIImageView!
    @IBOutlet weak var membersGroupName: UILabel!
    @IBOutlet weak var memberName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func removeBtnPress(_ sender: UIButton) {
        self.delegate?.deleteButtonTapped(name: idLbl.text!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
