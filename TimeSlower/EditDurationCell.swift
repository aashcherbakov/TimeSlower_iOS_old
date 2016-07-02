//
//  EditDurationCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

class EditDurationCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    @IBOutlet weak var control: UIControl!
    static let screenHeight = UIScreen.mainScreen().bounds.height

    static let expandedHeight: CGFloat = round(0.33 * screenHeight)
    static let defaultHeight: CGFloat = 50
}
