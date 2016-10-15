//
//  ProfileEditingTableViewCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/6/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit



class ProfileEditingTableViewCell: UITableViewCell {
    
    /**
     Enum that describes current state of cell
     
     - Default: default state
     - Editing: cell contains data
     */
    enum EditingState {
        case `default`
        case editing
    }
    
    fileprivate struct Constants {
        static let placeholderYPadding: CGFloat = -6.0
    }
    
    // MARK: Properties
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    @IBOutlet weak var viewForPicker: UIView!
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var separatorLineHeight: NSLayoutConstraint!
    
    
    fileprivate var type: ProfileEditingCellType?
    fileprivate var config: ProfileEditingCellConfig?
    
    fileprivate var selectedValue: AnyObject? {
        didSet {
            guard let type = type else { return }
            let state: EditingState = selectedValue != nil ? .editing : .default
            updateTextFieldWithValue(selectedValue)
            config?.updateValue(selectedValue, forType: type)
            updateDesignForState(state, cellType: type)
        }
    }
    
    fileprivate lazy var countryPicker: CountryPicker? = {
        guard let countryPicker = self.config?.defaultCountryPicker() else { return nil }
        countryPicker.delegate = self
        self.selectedValue = countryPicker.selectedCountryName as AnyObject?
        return countryPicker
    }()
    
    fileprivate lazy var datePicker: UIDatePicker? = {
        guard let datePicker = self.config?.defatultDatePicker() else { return nil }
//        datePicker.rx_date
//            .subscribeNext { [weak self] (date) -> Void in
//                self?.selectedValue = date
//            }
//            .addDisposableTo(self.disposable)
        return datePicker
    }()
    
    // MARK: - UITableViewCell lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEvents()
    }
    
    func setupWith(_ type: ProfileEditingCellType, config: ProfileEditingCellConfig) {
        self.type = type
        self.config = config
        setupDesign()
        setupData()
    }
    
    // MARK: Internal Methods
    
    func setExpended(_ expended: Bool) {
        if expended {
            setupPickerView(forType: type)
        } 
    }
    
    func shouldExpand() -> Bool {
        return self.type != .Name
    }
    
    // MARK: - Setup Methods
    
    fileprivate func setupEvents() {
//        textField.rx_text
//            .subscribeNext { [weak self] (text) -> Void in
//                self?.selectedValue = text.characters.count > 0 ? text : nil
//            }
//            .addDisposableTo(disposable)
    }
    
    fileprivate func setupData() {
        guard let type = type else { return }
        selectedValue = config?.preparedValueForType(type)
    }
    
    fileprivate func setupDesign() {
        textField.delegate = self
        textField.isUserInteractionEnabled = (type == .Name)
        textField.placeholder = type?.rawValue.capitalized
        textField.floatingLabelActiveTextColor = UIColor.darkRed()
        textField.floatingLabelTextColor = UIColor.darkRed()
        textField.font = UIFont.sourceSansRegular()
        textField.placeholderYPadding = Constants.placeholderYPadding
        separatorLine.alpha = (type == .Country) ? 0.0 : 1.0
        separatorLineHeight.constant = kDefaultSeparatorHeight
        
        if let cellType = type {
            iconImageView.image = config?.iconForCellType(cellType, forState: .default)
        }
    }
    
    // MARK: - Private Functions
    
    fileprivate func setupPickerView(forType type: ProfileEditingCellType?) {
        guard let type = type else { return }
        
        var picker: UIView!
        switch type {
        case .Birthday: picker = datePicker
        case .Country: picker = countryPicker
        default: return
        }
        
        viewForPicker.addSubview(picker)
    }
    
    fileprivate func updateTextFieldWithValue(_ value: AnyObject?) {
        if let string = value as? String {
            textField.text = string
        } else if let date = value as? Date {
            textField.text = config?.shortDateFormatter.string(from: date)
        }        
    }
    
    fileprivate func updateDesignForState(_ cellState: EditingState?, cellType: ProfileEditingCellType?) {
        guard let type = cellType, let state = cellState else { return }
        iconImageView.image = config?.iconForCellType(type, forState: state)
        textField.textColor = config?.textColorForState(state)
    }
}

extension ProfileEditingTableViewCell : CountryPickerDelegate {
    func countryPicker(_ picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        selectedValue = name as AnyObject?
    }
}

extension ProfileEditingTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
