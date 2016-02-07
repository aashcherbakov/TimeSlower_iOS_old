//
//  EditActivityNameCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift

/**
 UITableViewCell subclass used to enter/edit activity name. Contains TextfieldView to 
 collect data and, in expanded state, - DefaultActivitySelector.
*/
class EditActivityNameCell: UITableViewCell {
    
    @IBOutlet weak var textFieldView: TextfieldView!
    @IBOutlet weak var defaultActivitySelectorView: DefaultActivitySelector!
    
    private(set) var selectedName = Variable<String>("")
    private(set) var textFieldIsEditing = Variable<Bool>(true)
    private var disposableBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupData()
        setupEvents()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        defaultActivitySelectorView.setupCollectionViewItemSize()
    }
    
    // MARK: - Private Methods
    
    func setupData() {
        textFieldView.setup(withType: .ActivityName, delegate: self)
    }
    
    func setupEvents() {
        defaultActivitySelectorView.addTarget(self, action: Selector("defaultActivitySelected:"), forControlEvents: .ValueChanged)
    }
    
    func defaultActivitySelected(value: Int) {
        if let name = defaultActivitySelectorView.selectedActivityName {
            textFieldView.setText(name)
            selectedName.value = name
        }
    }
}

extension EditActivityNameCell: TextFieldViewDelegate {
    func textFieldViewDidReturn(withText: String) {
        textFieldIsEditing.value = false
        selectedName.value = withText
    }
    
    func textFieldViewDidBeginEditing() {
        textFieldIsEditing.value = true
    }
}