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
    
    static let expandedHeight: CGFloat = 160
    static let defaultHeight: CGFloat = 50
}
