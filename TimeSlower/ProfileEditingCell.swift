//
//  ProfileEditingCell.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

internal protocol ProfileEditingCell: class {
    
    weak var textfieldView: TextfieldView! { get }
    weak var textfieldViewHeight: NSLayoutConstraint! { get }

    func setup(withConfiguration config: TextfieldConfiguration)
    
}

extension ProfileEditingCell {
    
    func setup(withConfiguration config: TextfieldConfiguration) {
        textfieldView.setupWithConfig(config)
    }
    
}
