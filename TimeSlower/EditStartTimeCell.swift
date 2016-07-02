//
//  EditStartTimeCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 6/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

class EditStartTimeCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    
    @IBOutlet weak var control: UIControl!
    static let screenHeight = UIScreen.mainScreen().bounds.height

    static let expandedHeight: CGFloat = round(0.33 * screenHeight)
    static let defaultHeight: CGFloat = 50
    
    static func heightForState(state: EditActivityVC.EditingState) -> CGFloat {
        switch state {
        case .Name, .Basis:
            return 0
        default:
            return defaultHeight
        }
    }
}