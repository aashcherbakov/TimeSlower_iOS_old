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

    static let expandedHeight: CGFloat = round(0.24 * screenHeight)
    
    static func heightForState(_ state: EditActivityVC.EditingState) -> CGFloat {
        switch state {
        case .name:
            return 0
        default:
            return defaultHeight()
        }
    }
}
