//
//  SelectRowButton.swift
//  Pacer
//
//  Created by Alex Robinson on 4/30/15.
//  Copyright (c) 2015 Alex Robinson. All rights reserved.
//

import UIKit

enum SelectedState {
    case Active
    case Inactive
    case Calculated
}

class SelectRowButton: UIButton {
    var rowState = SelectedState.Inactive {
        didSet {
            self.refreshUI()
        }
    }
    func refreshUI() {
        switch rowState {
        case .Active:
            setImage(UIImage(named: "arrowActive"), forState: .Normal)
        case .Inactive:
            setImage(UIImage(named: "arrowInactive"), forState: .Normal)
        case .Calculated:
            setImage(UIImage(named: "arrowAnswer"), forState: .Normal)
        }
    }
}
