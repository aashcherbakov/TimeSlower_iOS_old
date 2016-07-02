//
//  EditNameCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 6/5/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

class EditNameCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    
    @IBOutlet weak var control: UIControl!
    static let screenHeight = UIScreen.mainScreen().bounds.height
    static let expandedHeight: CGFloat = round(0.43 * screenHeight)
    static let defaultHeight: CGFloat = 50
    
    static func heightForState(state: EditActivityVC.EditingState) -> CGFloat {
        return defaultHeight
    }
}
