//
//  GroupTagListTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 2/18/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
protocol CellSeeMoreSubclassDelegate: class {
    func buttonTapped(name: String)
}
class GroupTagListTableViewCell: UITableViewCell {
  weak var delegate: CellSeeMoreSubclassDelegate?
    @IBOutlet weak var seeMoreBt: UIButton!
    @IBOutlet weak var deedIcon: UIImageView!
    @IBOutlet weak var deedEndorse: UILabel!
    @IBOutlet weak var deedView: UILabel!
    @IBOutlet weak var deedAddress: UILabel!
    @IBOutlet weak var deedLocationKm: UILabel!
    @IBOutlet weak var deedDate: UILabel!
    @IBOutlet weak var deedName: UILabel!
    @IBOutlet weak var deedImg: UIImageView!
    @IBOutlet weak var deedTaggerId: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    @IBAction func seeMoreBtnPress(_ sender: UIButton) {
        self.delegate?.buttonTapped(name:deedTaggerId.text! )
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
