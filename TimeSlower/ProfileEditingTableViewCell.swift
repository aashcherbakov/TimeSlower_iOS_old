//
//  ProfileEditingTableViewCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/6/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import JVFloatLabeledText
import RxCocoa
import RxSwift

/**
 Enum of strings that descrybes cell type
 
 - Name:     to enter name
 - Country:  to select country
 - Birthday: to select birthday
 */
enum ProfileEditingCellType: String {
    case Name = "name"
    case Country = "country"
    case Birthday = "birthday"
}

class ProfileEditingTableViewCell: UITableViewCell {
    
    /**
     Enum that describes current state of cell
     
     - Default: default state
     - Editing: cell contains data
     */
    enum EditingState {
        case Default
        case Editing
    }
    
    private let disposable = DisposeBag()
    private var type: ProfileEditingCellType?

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    
    // MARK: - Setup Methods
    
    func setupWith(type type: ProfileEditingCellType) {
        self.type = type
        self.setupDesignForState(.Default, cellType: type)
    }
    
    private func setupDesignForState(cellState: EditingState?, cellType: ProfileEditingCellType?) {
        guard let type = cellType, state = cellState else { return }
        self.iconImageView.image = self.iconForCellType(type, forState: state)
        self.textField.textColor = self.textColorForState(state)
        self.textField.userInteractionEnabled = (cellType == .Name)
        self.textField.floatingLabel.text = cellType?.rawValue.capitalizedString
        
        self.bindTextField()
    }
    
    private func bindTextField() {
        self.textField.rx_text
            .subscribeNext { [unowned self] (text) -> Void in
                let state: EditingState = (text.characters.count > 0) ? .Editing : .Default
                self.setupDesignForState(state, cellType: self.type)
            }
            .addDisposableTo(disposable)
    }
    
    // MARK: - Private Functions
    
    private func iconForCellType(type: ProfileEditingCellType, forState state: EditingState) -> UIImage? {
        let suffix = (state == .Editing) ? "Selected" : ""
        let imageName = type.rawValue + "Icon" + suffix
        return UIImage(named: imageName)
    }
    
    private func textColorForState(state: EditingState) -> UIColor {
        switch state {
        case .Default: return UIColor.lightGray()
        case .Editing: return UIColor.darkGray()
        }
    }
}
