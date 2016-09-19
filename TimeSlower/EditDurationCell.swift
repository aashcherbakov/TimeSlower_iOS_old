//
//  EditDurationCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

class EditDurationCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    @IBOutlet weak var control: ObservableControl!
    static let screenHeight = UIScreen.main.bounds.height

    static let expandedHeight: CGFloat = round(0.33 * screenHeight)
    
    static func heightForState(_ state: EditActivityVC.EditingState) -> CGFloat {
        switch state {
        case .name, .basis, .startTime:
            return 0
        default:
            return defaultHeight()
        }
    }
}
