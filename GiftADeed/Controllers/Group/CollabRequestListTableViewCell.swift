//
//  CollabRequestListTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 5/31/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit
protocol CellReqListSubclassDelegate: class {
    func acceptButtonTapped(id: String,name:String,creator_id:String)
     func rejectButtonTapped(id: String,name:String,creator_id:String)
}

class CollabRequestListTableViewCell: UITableViewCell {
    @IBOutlet weak var creatorId: UILabel!
    @IBOutlet weak var idlbl: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descriptions: UILabel!
    @IBOutlet weak var date: UILabel!
    weak var delegate: CellReqListSubclassDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func rejectBtnPress(_ sender: UIButton) {
        self.delegate?.rejectButtonTapped(id: idlbl.text!, name:name.text!, creator_id: creatorId.text!)
    }
    @IBAction func acceptBTnPress(_ sender: UIButton) {
        self.delegate?.acceptButtonTapped(id: idlbl.text!, name:name.text!, creator_id: creatorId.text!)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
