//
//  EditActivityTextfieldView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/2/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import JVFloatLabeledTextField

enum TextFieldViewType: String {
    case ActivityName = "activityNameIcon"
    case StartTime = "startTimeIcon"
    case Duration = "durationIcon"
    case Notification = "notificationIcon"
}

class TextfieldView: UIView {
    
    private struct Constants {
        static let placeholderYPadding: CGFloat = -6.0
    }
    
    // MARK: - Variables
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    private var type: TextFieldViewType?
    private var viewModel: TextfieldViewModel?
    private var disposable = DisposeBag()
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    // MARK: - Internal Methods
    
    func setup(withType type: TextFieldViewType) {
        self.type = type
        setupData()
        setupEvents()
        setupDesign()
    }
    
    // MARK: - Setup Methods
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(TextfieldView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupData() {
        viewModel = TextfieldViewModel(withTextField: textField)
    }
    
    private func setupEvents() {
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
        
        textField.delegate = viewModel
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
        textField.textColor = viewModel?.textColorForState(.Empty)
        imageView.image = viewModel?.iconForType(type, state: state)
    }
}




