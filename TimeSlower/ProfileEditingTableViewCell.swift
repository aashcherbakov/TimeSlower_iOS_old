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

enum ProfileEditingCellType: String {
    case Name = "name"
    case Country = "country"
    case Birthday = "birthday"
}

class ProfileEditingTableViewCell: UITableViewCell {
    
    enum EditingState {
        case Default
        case Selected
        case Error
        case Valid
    }
    
    private var state: EditingState!

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindTextField() {
        let disposable = DisposeBag()
        self.textField.rx_text
            .subscribeNext { (text) -> Void in
            if text.characters.count > 0 {
                self.state = .Valid
            } else {
                self.state = .Default
            }
        }
        .addDisposableTo(disposable)
    }
    
    func iconForCellType(type: ProfileEditingCellType, state selected: Bool) -> UIImage? {
        let suffix = (selected) ? "Selected" : ""
        let imageName = type.rawValue + "Icon" + suffix
        return UIImage(named: imageName)
    }
}
