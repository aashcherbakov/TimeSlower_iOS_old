//
//  EditActivityTextfieldView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import RxSwift
import JVFloatLabeledTextField

/**
 *  Protocol used to transfer UITextFieldDelegate messages like didBeginEditing:, etc.
 */
protocol TextFieldViewDelegate {
    /**
     Message sent to delegate when user taps "return" button
     */
    func textFieldViewDidReturn(withText: String)
    
    /**
     Message sent to delegate when textfield becomes active
     */
    func textFieldViewDidBeginEditing()
}

/**
 Enum that represents type of textfield. Depending on type, icon and placeholder is set.
 */
enum TextFieldViewType: String {
    case ActivityName = "activityNameIcon"
    case StartTime = "startTimeIcon"
    case Duration = "durationIcon"
    case Notification = "notificationIcon"
}

/** 
 Class that represents a view with JVFloatLabeledTextField. Depending on set type,
 it will have pre-defined icon and a placeholder text. Changes state from .Empty to .DataEntered,
 which causes change of icon color.
*/
class TextfieldView: UIView {
    
    private struct Constants {
        static let placeholderYPadding: CGFloat = -6.0
    }
    
    // MARK: - Variables
    
    @IBOutlet private var view: UIView!
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    @IBOutlet weak var imageView: UIImageView!
    
    private var viewModel: TextfieldViewModel?
    private var type: TextFieldViewType?
    private var disposable = DisposeBag()
    private var delegate: TextFieldViewDelegate?
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    // MARK: - Internal Methods
    
    /**
    Required setup method for textfield view
    
    - parameter type:     TextFieldViewType which will define design details of textfield view
    - parameter delegate: instance that is conforming to TextFieldViewDelegate protocol
    */
    func setup(withType type: TextFieldViewType, delegate: TextFieldViewDelegate) {
        self.type = type
        self.delegate = delegate
        
        setupData()
        setupEvents()
        setupDesign()
    }
    
    /**
     Method to set text displayed on textfield
     
     - parameter text: String
     */
    func setText(text: String?) {
        textField.text = text
        textField.resignFirstResponder()
        let state: TextFieldViewState = text?.characters.count > 0 ? .DataEntered : .Empty
        updateDesignForState(state)
    }
    
    // MARK: - Private Methods
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(TextfieldView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupData() {
        viewModel = TextfieldViewModel(withTextField: textField)
    }
    
    private func setupEvents() {
        // state depends on whether user has entered any text or not
        viewModel?.state?
            .subscribeNext { [weak self] (state) -> Void in
                self?.updateDesignForState(state)
            }
            .addDisposableTo(disposable)
    }
    
    private func setupDesign() {
        guard let type = type else { return }
        imageView.image = viewModel?.iconForType(type, state: .Empty)
        setupTextfield()
    }
    
    private func setupTextfield() {
        guard let type = type else { return }
        
        textField.delegate = self
        textField.userInteractionEnabled = (type == .ActivityName)
        textField.placeholder = viewModel?.placeholderForType(type)
        textField.floatingLabelActiveTextColor = UIColor.darkRed()
        textField.floatingLabelTextColor = UIColor.darkRed()
        textField.font = UIFont.sourceSansRegular()
        textField.placeholderYPadding = Constants.placeholderYPadding
        textField.textColor = viewModel?.textColorForState(.Empty)
    }
    
    private func updateDesignForState(state: TextFieldViewState?) {
        guard let type = type, state = state else { return }
        textField.textColor = viewModel?.textColorForState(state)
        imageView.image = viewModel?.iconForType(type, state: state)
    }
}

// MARK: - UITextFieldDelegate

extension TextfieldView : UITextFieldDelegate {
    // we need to use delegate to forward existing API calls
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.textFieldViewDidReturn(textField.text!)
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.textFieldViewDidBeginEditing()
    }
}




