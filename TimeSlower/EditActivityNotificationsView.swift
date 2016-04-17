//
//  File.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/21/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// UITableViewCell subclass to turn on/off notifications for activity
class EditActivityNotificationsView: UIView {
    
    // MARK: - Properties
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!
    
    /// Bool true if notification switch is on
    var notificationsOn = Variable<Bool>(true)
    private let disposableBag = DisposeBag()
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupDesign()
        setupEvents()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed(EditActivityNotificationsView.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        textfieldView.setup(withType: .Notification, delegate: nil)
        notificationSwitch.on = notificationsOn.value
        notificationSwitch.onTintColor = UIColor.purpleRed()
    }
    
    private func setupEvents() {
        notificationSwitch.rx_value
            .subscribeNext { [weak self] (on) -> Void in
                self?.notificationsOn.value = on
                let text = on ? "on" : "off"
                self?.textfieldView.setText(text)
            }
            .addDisposableTo(disposableBag)
    }
}
