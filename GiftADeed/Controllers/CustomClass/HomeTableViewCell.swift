//
//  HomeTableViewCell.swift
//  GiftADeed
//
//  Created by nilesh sinha on 05/04/18.
//  Copyright © 2018 Mayur Yergikar. All rights reserved.
//

import UIKit
protocol CellSubclassDelegate: class {
    func detailButtonTapped(name: String)
}

class HomeTableViewCell: UITableViewCell {
    weak var delegate: CellSubclassDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    @IBAction func detailBtnPress(_ sender: UIButton) {
        self.delegate?.detailButtonTapped(name: taggedId.text!)
    }
    @IBOutlet weak var taggedId: UILabel!
    @IBOutlet weak var outletIconImg: UIImageView!
    @IBOutlet weak var outletCharacterImg: UIImageView!
    @IBOutlet weak var outletNeedLabel: UILabel!
    @IBOutlet weak var outletAddressLabel: UILabel!
    @IBOutlet weak var outletDateLabel: UILabel!
    @IBOutlet weak var outletViewsLabel: UILabel!
    @IBOutlet weak var outletEndorseLabel: UILabel!
    @IBOutlet weak var outletKMAwayLabel: UILabel!
    @IBOutlet weak var outletGiftNowLabel: UIButton!
    @IBOutlet weak var outletTagStatusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
