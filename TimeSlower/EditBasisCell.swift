//
//  EditBasisCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 6/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

class EditBasisCell: UITableViewCell, ObservableControlCell, ExpandableCell {

    @IBOutlet weak var control: ObservableControl!
    static let screenHeight = UIScreen.main.bounds.height

    static let expandedHeight: CGFloat = round(multiplier() * screenHeight)
    
    static func heightForState(_ state: EditActivityVC.EditingState) -> CGFloat {
        switch state {
        case .name:
            return 0
        default:
            return defaultHeight()
        }
    }
    
    private static func multiplier() -> CGFloat {
        if let currentScreenHeight = ScreenHight(rawValue: screenHeight) {
            switch currentScreenHeight {
            case .iPhone5:
                return 0.24
            default:
                return 0.2
            }
        }
        return 0.2
    }
}
