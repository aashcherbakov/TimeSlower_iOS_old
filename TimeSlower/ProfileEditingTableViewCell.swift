//
//  ProfileEditingTableViewCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/6/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBlocking
import PureLayout
import JVFloatLabeledTextField

/**
 Enum of strings that descrybes cell type
 
 - Name:     to enter name
 - Country:  to select country
 - Birthday: to select birthday
 */
enum ProfileEditingCellType: String {
    case Name = "name"
    case Country = "country"
    case Birthday = "birthday"
}

class ProfileEditingTableViewCell: UITableViewCell {
    
    /**
     Enum that describes current state of cell
     
     - Default: default state
     - Editing: cell contains data
     */
    enum EditingState {
        case Default
        case Editing
    }
    
    // MARK: Properties
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    @IBOutlet weak var viewForPicker: UIView!
    
    private let disposable = DisposeBag()
    private var type: ProfileEditingCellType?
    private var config: ProfileEditingCellConfig?
    
    private var selectedValue: AnyObject? {
        didSet {
            guard let value = selectedValue, type = type else { return }
            updateTextFieldWithValue(value)
            config?.updateValue(value, forType: type)
            updateDesignForState(.Editing, cellType: type)
        }
    }
    
    private lazy var countryPicker: CountryPicker? = {
        guard let countryPicker = self.config?.defaultCountryPicker() else { return nil }
        countryPicker.delegate = self
        self.selectedValue = countryPicker.selectedCountryName
        return countryPicker
    }()
    
    private lazy var datePicker: UIDatePicker? = {
        guard let datePicker = self.config?.defatultDatePicker() else { return nil }
        datePicker.rx_date
            .subscribeNext { [weak self] (date) -> Void in
                self?.selectedValue = date
            }
            .addDisposableTo(self.disposable)
        return datePicker
    }()
    
    // MARK: - UITableViewCell lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEvents()
    }
    
    func setupWith(type type: ProfileEditingCellType, config: ProfileEditingCellConfig) {
        self.type = type
        self.config = config
        setupDesign()
    }
    
    // MARK: Internal Methods
    
    func setExpended(expended: Bool) {
        if expended {
            setupPickerView(forType: type)
        }
    }
    
    func shouldExpand() -> Bool {
        return self.type != .Name
    }
    
    // MARK: - Setup Methods
    
    private func setupEvents() {
        textField.rx_text
            .subscribeNext { [weak self] (text) -> Void in
                let state: EditingState = (text.characters.count > 0) ? .Editing : .Default
                self?.updateDesignForState(state, cellType: self?.type)
            }
            .addDisposableTo(disposable)
    }
    
    private func setupDesign() {
        textField.delegate = self
        textField.userInteractionEnabled = (type == .Name)
        textField.placeholder = type?.rawValue.capitalizedString
        textField.floatingLabelActiveTextColor = UIColor.darkRed()
        textField.floatingLabelTextColor = UIColor.darkRed()
        
        if let cellType = type {
            iconImageView.image = config?.iconForCellType(cellType, forState: .Default)
        }
    }
    
    // MARK: - Private Functions
    
    private func setupPickerView(forType type: ProfileEditingCellType?) {
        guard let type = type else { return }
        
        var picker: UIView!
        switch type {
        case .Birthday: picker = datePicker
        case .Country: picker = countryPicker
        default: return
        }
        
        viewForPicker.addSubview(picker)
        picker.autoCenterInSuperview()
    }
    
    private func updateTextFieldWithValue(value: AnyObject) {
        if let string = value as? String {
            textField.text = string
        } else if let date = value as? NSDate {
            textField.text = config?.shortDateFormatter.stringFromDate(date)
        }
    }
    
    private func updateDesignForState(cellState: EditingState?, cellType: ProfileEditingCellType?) {
        guard let type = cellType, state = cellState else { return }
        iconImageView.image = config?.iconForCellType(type, forState: state)
        textField.textColor = config?.textColorForState(state)
    }
}

extension ProfileEditingTableViewCell : CountryPickerDelegate {
    func countryPicker(picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        selectedValue = name
    }
}

extension ProfileEditingTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
