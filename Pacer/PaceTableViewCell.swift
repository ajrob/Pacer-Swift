//
//  PaceTableViewCell.swift
//  Pacer
//
//  Created by Alex Robinson on 5/3/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class PaceTableViewCell: UITableViewCell {

    @IBOutlet weak var paceUnitsButton: UIButton!
    @IBOutlet weak var paceValueLabel: UILabel!
    @IBOutlet weak var selectRowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
