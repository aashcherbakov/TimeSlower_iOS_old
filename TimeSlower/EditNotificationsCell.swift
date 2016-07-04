//
//  EditNotificationsCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

class EditNotificationsCell: UITableViewCell, ExpandableCell, ObservableControlCell {
    @IBOutlet weak var control: ObservableControl!
    static let expandedHeight: CGFloat = 50

    static func heightForState(state: EditActivityVC.EditingState) -> CGFloat {
        switch state {
        case .Name, .Basis, .StartTime, .Duration:
            return 0
        default:
            return defaultHeight()
        }
    }
}
