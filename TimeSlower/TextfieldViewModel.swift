//
//  TextfieldViewModel.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import JVFloatLabeledTextField

enum TextFieldViewState {
    case Empty
    case DataEntered
}

class TextfieldViewModel: NSObject {
    
    private var textField: JVFloatLabeledTextField
    private var disposable = DisposeBag()
    
    var state: BehaviorSubject<TextFieldViewState>?
    
    init(withTextField: JVFloatLabeledTextField) {
        self.textField = withTextField
        
        super.init()

        self.setupEvents()
    }
    
    func setupEvents() {
        state = BehaviorSubject(value: .Empty)
        textField.rx_text
            .subscribeNext { [weak self] (text) -> Void in
                let editingState: TextFieldViewState = text.characters.count > 0 ? .DataEntered : .Empty
                self?.state?.onNext(editingState)
            }
            .addDisposableTo(disposable)
    }
    
    // MARK: - Config methods
    
    func iconForType(type: TextFieldViewType, state: TextFieldViewState) -> UIImage? {
        let suffix = (state == .Empty) ? "" : "Black"
        let imageName = type.rawValue + suffix
        return UIImage(named: imageName)
    }
    
    func placeholderForType(type: TextFieldViewType) -> String {
        switch type {
        case .ActivityName: return "Activity name"
        case .Duration: return "Duration"
        case .Notification: return "Notification"
        case .StartTime: return "Start time"
        }
    }
    
    func textColorForState(state: TextFieldViewState?) -> UIColor? {
        guard let state = state else { return nil }
        switch state {
        case .Empty: return UIColor.lightGray()
        case .DataEntered: return UIColor.darkGray()
        }
    }
    
    func stringFromData(data: AnyObject?) -> String? {
        if let string = data as? String {
            return string
        } else if let date = data as? NSDate {
            return shortDateFormatter.stringFromDate(date)
        } else {
            return nil
        }
    }
    
    /// Should be a singleton -> refactor
    private var shortDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter
    }()

}

extension TextfieldViewModel : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}