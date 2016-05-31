//
//  EditActivityDurationView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift

/// UITableViewCell subclass to edit duration of activity
class EditActivityDurationView: UIControl {
    
    private struct Constants {
        static let defaultDuration = 30
    }
    
    // MARK: - Properties
    
    
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    
    /// Duration of activity in minutes. Observable.
    var activityDuration = Variable<Int?>(nil)
    private var disposableBag = DisposeBag()
    
    var value: Int?
    
    // MARK: - Overriden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupDesign()
        setupEvents()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityDurationView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    // MARK: - Actions
    
    @IBAction func quantityButtonTapped(sender: UIButton) {
        if let value = activityDuration.value {
            let oldValue = value
            var newValue = 0
            switch sender.tag {
            case 0:
                if oldValue > 5 {
                    newValue = oldValue - 5
                }
            case 1:
                newValue = oldValue + 5
            default: return
            }
            activityDuration.value = newValue
            self.value = newValue
            sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupDesign() {
        if activityDuration.value == nil {
            activityDuration.value = Constants.defaultDuration
        }
        
        textfieldView.setup(withType: .Duration, delegate: nil)
        separatorLineHeight.constant = kDefaultSeparatorHeight
    }
    
    private func setupEvents() {
        
        
        
        activityDuration
            .subscribeNext { [weak self] (value) -> Void in
                if let value = value {
                    self?.durationLabel.text = "\(value) min"
                    let hours: Double = Double(value) / 60.0
                    self?.textfieldView.setText("\(hours.format(".1")) hours")
                }
            }
            .addDisposableTo(disposableBag)
    }
    
}