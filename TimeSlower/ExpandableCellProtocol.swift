//
//  ExpandableCellProtocol.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

protocol ExpandableCell {
    static var expandedHeight: CGFloat { get }
    static func defaultHeight() -> CGFloat
    static func heightForState(_ state: EditActivityVC.EditingState) -> CGFloat
}

extension ExpandableCell where Self : UITableViewCell {
    static func defaultHeight() -> CGFloat {
        return 50
    }
}
