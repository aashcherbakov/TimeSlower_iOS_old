//
//  EditNameCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 6/5/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveSwift

class EditNameCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    
    @IBOutlet weak var control: ObservableControl!
    static let screenHeight = UIScreen.main.bounds.height
    static let expandedHeight: CGFloat = round(0.43 * screenHeight)
    
    static func heightForState(_ state: EditActivityVC.EditingState) -> CGFloat {
        return defaultHeight()
    }
}
