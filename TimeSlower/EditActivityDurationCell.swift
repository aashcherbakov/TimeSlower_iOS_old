//
//  EditActivityDurationCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/13/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift

/// UITableViewCell subclass to edit duration of activity
class EditActivityDurationCell: UITableViewCell {
    
    private struct Constants {
        static let defaultDuration = 30
    }

    // MARK: - Properties
    
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var durationLabel: UILabel!
    
    /// Duration of activity in minutes. Observable.
    var activityDuration = Variable<Int?>(nil)
    private var disposableBag = DisposeBag()
    
    // MARK: - Overriden Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupDesign()
        setupEvents()
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
        }
    }
    
    // MARK: - Private Methods
    
    private func setupDesign() {
        if activityDuration.value == nil {
            activityDuration.value = Constants.defaultDuration
        }
        
        textfieldView.setup(withType: .Duration, delegate: nil)
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
