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
    weak var delegate: ProfileEditingCellDelegate? { get set }
    
    func setup(withConfiguration config: TextfieldConfiguration)
    func setDefaultValue()
    func saveValue()
    func setValue(value: String)
}

extension ProfileEditingCell {
    
    func setup(withConfiguration config: TextfieldConfiguration) {
        textfieldView.setupWithConfig(config)
    }
    
    func setValue(value: String) {
        textfieldView.setText(value)
    }
}
