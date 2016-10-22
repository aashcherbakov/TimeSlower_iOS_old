//
//  ProfileCountryCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit

/// ProfileEditingCell that displays country picker and TextfieldView
class ProfileCountryCell: UITableViewCell, ProfileEditingCell {
   
    @IBOutlet weak var textfieldView: TextfieldView!
    @IBOutlet weak var countryPicker: CountryPicker!
    @IBOutlet weak var textfieldViewHeight: NSLayoutConstraint!

    /// ProfileEditingCellDelegate
    weak var delegate: ProfileEditingCellDelegate?
    fileprivate var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countryPicker.delegate = self
        
        textfieldView.text.producer.startWithValues { [weak self] (text) in
            guard let text = text else { return }
            self?.countryPicker.setSelectedCountryName(text, animated: true)
            self?.delegate?.profileEditingCellDidUpdateValue(value: text, type: .Country)
        }
    }
    
    func setDefaultValue() {
        if textfieldView.textField.text == nil || textfieldView.textField.text == "" {
            textfieldView.setText("United States")
            countryPicker.setSelectedCountryName("United States", animated: false)
        }
    }
    
    func saveValue() {
        delegate?.profileEditingCellDidUpdateValue(value: countryPicker.selectedCountryName, type: .Country)
    }
    
    func setValue(value: String) {
        textfieldView.setText(value)
        countryPicker.setSelectedCountryName(value, animated: true)
    }
}


// MARK: - CountryPickerDelegate
extension ProfileCountryCell: CountryPickerDelegate {
    func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        textfieldView.setText(name)
        
        timer?.terminate()
        timer = Timer(1) { [weak self] in
            self?.delegate?.profileEditingCellDidUpdateValue(value: name, type: .Country)

            self?.timer?.terminate()
        }
        
        timer?.start()
    }
}
