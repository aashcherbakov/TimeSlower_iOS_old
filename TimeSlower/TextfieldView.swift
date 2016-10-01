//
//  EditActivityTextfieldView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveObjC
import ReactiveObjCBridge
import Result

/** 
 Class that represents a view with JVFloatLabeledTextField. Depending on set type,
 it will have pre-defined icon and a placeholder text. Changes state from .Empty to .DataEntered,
 which causes change of icon color.
*/
class TextfieldView: UIView {
    
    fileprivate struct Constants {
        static let placeholderYPadding: CGFloat = -2
    }
    
    // MARK: - Variables
    
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet fileprivate var view: UIView!
    
    var text = MutableProperty<String?>(nil)
    var config: TextfieldConfiguration!
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    // MARK: - Internal Methods
    
    /**
    Required setup method for textfield view
    
    - parameter config:   TextfieldConfiguration type which will define design details of textfield view
    - parameter delegate: instance that is conforming to TextFieldViewDelegate protocol
    */
    func setupWithConfig(_ config: TextfieldConfiguration) {
        self.config = config
        
        setupEvents()
        setupDesign()
    }
    
    /**
     Method to set text displayed on textfield
     
     - parameter text: String
     */
    func setText(_ text: String?) {
        textField.text = text
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(TextfieldView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    fileprivate func setupEvents() {
        let textDirectSignal = textField.rac_values(forKeyPath: "text", observer: self).toSignalProducer()
        let textInputSignal = textField.rac_textSignal().toSignalProducer()
        
        SignalProducer.combineLatest([textDirectSignal, textInputSignal])
            .map { (strings) -> Bool in
                let combinedString = strings.reduce("") { $0 + ($1 as! String) }
                return combinedString.characters.count > 0
            }
            .skipRepeats()
            .startWithResult { [weak self] (result) in
                if let valid = result.value {
                    self?.textField.textColor = valid ? UIColor.darkGray() : UIColor.lightGray()
                    self?.imageView.image = valid ? self?.config.iconHighlighted : self?.config.icon
                }
            }
    }
    
    fileprivate func setupDesign() {
        textField.isUserInteractionEnabled = config.textFieldInteractionEnabled
        textField.placeholder = config.placeholder
        textField.floatingLabelActiveTextColor = UIColor.purpleRed()
        textField.floatingLabelTextColor = UIColor.purpleRed()
        textField.font = UIFont.sourceSansRegular()
        textField.textColor = UIColor.lightGray()
        textField.placeholderYPadding = Constants.placeholderYPadding
    }
}



