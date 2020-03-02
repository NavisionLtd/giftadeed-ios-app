//
//  ResourceDataTableViewCell.swift
//  GiftADeed
//
//  Created by Darshan on 4/3/19.
//  Copyright © 2019 Mayur Yergikar. All rights reserved.
//

import UIKit

class ResourceDataTableViewCell: UITableViewCell {

    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var myContent: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        //        super.setSelected(selected, animated: animated)
        //       self.accessoryType = selected ? .checkmark : .none
        
    }
}
