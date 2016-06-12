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
import ReactiveCocoa

/**
 UIView subclass used to enter/edit activity name. Contains TextfieldView to
 collect data and, in expanded state, - DefaultActivitySelector.
 */
class EditActivityNameView: UIControl {
    
    @IBOutlet weak var textFieldView: TextfieldView!
    @IBOutlet weak var defaultActivitySelectorView: DefaultActivitySelector!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    @IBOutlet var view: UIView!
    
    var expanded: Variable<Bool> = Variable(false)
    
    private(set) var selectedName = Variable<String>("")

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
    }
    
    // MARK: - Private Methods
    
    func setupData() {
        selectedName.subscribeNext { [weak self] (name) in
            self?.textFieldView.setupWithConfig(NameTextfield())
            self?.textFieldView.setText(name)
        }.addDisposableTo(disposableBag)
    }
    
    func setupEvents() {
        defaultActivitySelectorView.addTarget(self,
                                              action: #selector(EditActivityNameView.defaultActivitySelected(_:)),
                                              forControlEvents: .ValueChanged)
        
        textFieldView.textField.delegate = self
    
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

extension EditActivityNameView: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendActionsForControlEvents(.TouchUpInside)
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        sendActionsForControlEvents(.TouchUpInside)
    }
}