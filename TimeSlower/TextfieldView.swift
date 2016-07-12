//
//  EditActivityTextfieldView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import JVFloatLabeledTextField
import ReactiveCocoa

/** 
 Class that represents a view with JVFloatLabeledTextField. Depending on set type,
 it will have pre-defined icon and a placeholder text. Changes state from .Empty to .DataEntered,
 which causes change of icon color.
*/
class TextfieldView: UIView {
    
    private struct Constants {
        static let placeholderYPadding: CGFloat = -2
    }
    
    // MARK: - Variables
    
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private var view: UIView!
    
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
    func setupWithConfig(config: TextfieldConfiguration) {
        self.config = config
        
        setupEvents()
        setupDesign()
    }
    
    /**
     Method to set text displayed on textfield
     
     - parameter text: String
     */
    func setText(text: String?) {
        textField.text = text
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(TextfieldView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupEvents() {
        let textDirectSignal = textField.rac_valuesForKeyPath("text", observer: self).toSignalProducer()
        let textInputSignal = textField.rac_textSignal().toSignalProducer()        
        
        combineLatest([textDirectSignal, textInputSignal])
            .map({ (strings) -> Bool in
                let combinedString = strings.reduce("") { $0 + ($1 as! String) }
                return combinedString.characters.count > 0
            })
            .skipRepeats()
            .startWithNext { [weak self] (valid) in
                self?.textField.textColor = valid ? UIColor.darkGray() : UIColor.lightGray()
                self?.imageView.image = valid ? self?.config.iconHighlighted : self?.config.icon
        }
    }
    
    private func setupDesign() {
        textField.userInteractionEnabled = config.textFieldInteractionEnabled
        textField.placeholder = config.placeholder
        textField.floatingLabelActiveTextColor = UIColor.purpleRed()
        textField.floatingLabelTextColor = UIColor.purpleRed()
        textField.font = UIFont.sourceSansRegular()
        textField.textColor = UIColor.lightGray()
        textField.placeholderYPadding = Constants.placeholderYPadding
    }
}



