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
    static let screenHeight = UIScreen.mainScreen().bounds.height

    static let expandedHeight: CGFloat = round(0.19 * screenHeight)
    
    static func heightForState(state: EditActivityVC.EditingState) -> CGFloat {
        switch state {
        case .Name:
            return 0
        default:
            return defaultHeight()
        }
    }
}