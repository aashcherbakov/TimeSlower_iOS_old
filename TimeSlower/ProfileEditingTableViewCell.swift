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
    
    private struct Constants {
        static let placeholderYPadding: CGFloat = -6.0
    }
    
    // MARK: Properties
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textField: JVFloatLabeledTextField!
    @IBOutlet weak var viewForPicker: UIView!
    @IBOutlet weak var separatorLine: UIView!
    
    private let disposable = DisposeBag()
    private var type: ProfileEditingCellType?
    private var config: ProfileEditingCellConfig?
    
    private var selectedValue: AnyObject? {
        didSet {
            guard let type = type else { return }
            let state: EditingState = selectedValue != nil ? .Editing : .Default
            updateTextFieldWithValue(selectedValue)
            config?.updateValue(selectedValue, forType: type)
            updateDesignForState(state, cellType: type)
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
        setupData()
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
                self?.selectedValue = text.characters.count > 0 ? text : nil
            }
            .addDisposableTo(disposable)
    }
    
    private func setupData() {
        guard let type = type else { return }
        selectedValue = config?.preparedValueForType(type)
    }
    
    private func setupDesign() {
        textField.delegate = self
        textField.userInteractionEnabled = (type == .Name)
        textField.placeholder = type?.rawValue.capitalizedString
        textField.floatingLabelActiveTextColor = UIColor.darkRed()
        textField.floatingLabelTextColor = UIColor.darkRed()
        textField.font = UIFont.sourceSansRegular()
        textField.placeholderYPadding = Constants.placeholderYPadding
        separatorLine.alpha = (type == .Country) ? 0.0 : 1.0
        
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
    
    private func updateTextFieldWithValue(value: AnyObject?) {
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
