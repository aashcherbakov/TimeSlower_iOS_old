//
//  EditNameCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 6/5/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveCocoa

class EditNameCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    
    @IBOutlet weak var control: ObservableControl!
    static let screenHeight = UIScreen.mainScreen().bounds.height
    static let expandedHeight: CGFloat = round(0.43 * screenHeight)
    
    static func heightForState(state: EditActivityVC.EditingState) -> CGFloat {
        return defaultHeight()
    }
}
