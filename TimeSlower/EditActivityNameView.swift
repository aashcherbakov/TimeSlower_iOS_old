//
//  EditActivityNameView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/20/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

import UIKit
import RxSwift

/**
 UITableViewCell subclass used to enter/edit activity name. Contains TextfieldView to
 collect data and, in expanded state, - DefaultActivitySelector.
 */
class EditActivityNameView: UIView {
    
    @IBOutlet weak var textFieldView: TextfieldView!
    @IBOutlet weak var defaultActivitySelectorView: DefaultActivitySelector!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet var view: UIView!
    
    private(set) var selectedName = Variable<String>("")
    private(set) var textFieldIsEditing = Variable<Bool>(true)
    private var disposableBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        setupData()
        setupEvents()
        setupDesign()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("EditActivityNameView", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        defaultActivitySelectorView.setupCollectionViewItemSize()
        
        if selectedName.value == "" {
            textFieldView.textField.becomeFirstResponder()
        }
    }
    
    // MARK: - Private Methods
    
    func setupData() {
        textFieldView.setup(withType: .ActivityName, delegate: self)
    }
    
    func setupEvents() {
        defaultActivitySelectorView.addTarget(self, action: Selector("defaultActivitySelected:"), forControlEvents: .ValueChanged)
    }
    
    func setupDesign() {
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    func defaultActivitySelected(value: Int) {
        if let name = defaultActivitySelectorView.selectedActivityName {
            textFieldView.setText(name)
            selectedName.value = name
        }
    }
}

extension EditActivityNameView: TextFieldViewDelegate {
    func textFieldViewDidReturn(withText: String) {
        textFieldIsEditing.value = false
        selectedName.value = withText
    }
    
    func textFieldViewDidBeginEditing() {
        textFieldIsEditing.value = true
    }
}