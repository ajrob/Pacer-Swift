//
//  CustomMainTableViewCell.swift
//  Pacer
//
//  Created by Alex Robinson on 5/9/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

class CustomMainTableViewCell: UITableViewCell {

    @IBOutlet weak var selectRowButton: SelectRowButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
