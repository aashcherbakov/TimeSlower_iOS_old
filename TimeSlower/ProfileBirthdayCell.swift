//
//  ProfileBirthdayCell.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit
import ReactiveSwift

/// ProfileEditingCell that displays date picker and TextfieldView
class ProfileBirthdayCell: UITableViewCell, ProfileEditingCell {
   
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!
    
    private let dateFormatter = StaticDateFormatter.fullDateFormatter
    private var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textfieldView.text.producer.startWithValues { [weak self] (text) in
            guard let text = text, let date = self?.dateFormatter.date(from: text) else { return }
            self?.datePicker.setDate(date, animated: true)
            self?.notifyDelegate(ofNewValue: text)
        }
    }
    
    private func notifyDelegate(ofNewValue value: String) {
        timer?.terminate()
        timer = Timer(1) { [weak self] in
            self?.delegate?.profileEditingCellDidUpdateValue(value: value, type: .Birthday)
            self?.timer?.terminate()
        }
        
        timer?.start()
    }
    
    weak var delegate: ProfileEditingCellDelegate?
    
    func setDefaultValue() {
        if textfieldView.textField.text == "" {
            textfieldView.setText(dateFormatter.string(from: datePicker.date))
        }
    }
    
    func saveValue() {
        let date = dateFormatter.string(from: datePicker.date)
        textfieldView.setText(date)
    }
    
    func setValue(value: String) {
        if let date = dateFormatter.date(from: value) {
            textfieldView.setText(value)
            datePicker.setDate(date, animated: true) 
        }
    }
    
    @IBAction func didSelectDate(_ sender: UIDatePicker) {
        let date = dateFormatter.string(from: sender.date)
        textfieldView.setText(date)
    }
    
}

