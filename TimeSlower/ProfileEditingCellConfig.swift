//
//  ProfileEditingCellConfig.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 12/30/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

/// Class to configure ProfileEditingTableViewCell
class ProfileEditingCellConfig: NSObject {
    
    private(set) var birthday: NSDate?
    private(set) var name: String?
    private(set) var country: String?
    
    // MARK: Initializer
    
    init(withProfile: Profile?) {
        if let profile = withProfile {
            birthday = profile.birthday
            name = profile.name
            country = profile.country
        }
    }
        
    // MARK: - Internal Methods
    
    /**
    [tested]
    Method to update private property (name, birthday or country) for appropriate type.
    
    - parameter value: AnyObject for passing both String and NSDate type
    - parameter type:  ProfileEditingCellType of the cell
    */
    func updateValue(value: AnyObject?, forType type: ProfileEditingCellType) {
        guard let value = value else { return }
        
        if !value.isKindOfClass(NSNull) {
            switch type {
            case .Name: name = value as? String
            case .Birthday: birthday = value as? NSDate
            case .Country: country = value as? String
            }
        }
    }
    
    /**
     Returns value of approptiate property for type in form of AnyObject
     
     - parameter type: ProfileEditingCellType of the cell
     
     - returns: AnyObject? which can contain String or NSDate (for now)
     */
    func preparedValueForType(type: ProfileEditingCellType) -> AnyObject? {       
        switch type {
        case .Name: return name
        case .Birthday: return birthday
        case .Country: return country
        }
    }
    
    /**
    [tested]
    Returns icon for type and state - gray for default, black for active
    
    - parameter type:  ProfileEditingCellType of the cell
    - parameter state: ProfileEditingTableViewCell.EditingState - state in which label is now (editing or default)
    
    - returns: UIImage? for given type
    */
    func iconForCellType(type: ProfileEditingCellType,
        forState state: ProfileEditingTableViewCell.EditingState) -> UIImage? {
            let suffix = (state == .Editing) ? "Selected" : ""
            let imageName = type.rawValue + "Icon" + suffix
            return UIImage(named: imageName)
    }
    
    /// UIColor instance for EditingState
    func textColorForState(state: ProfileEditingTableViewCell.EditingState) -> UIColor {
        switch state {
        case .Default: return UIColor.lightGray()
        case .Editing: return UIColor.darkGray()
        }
    }
    
    /// CountryPicker with preselected country - based on user location
    func defaultCountryPicker() -> CountryPicker {
        let countryPicker = CountryPicker()
        let userCountry = (country != nil) ? country : Profile.defaultCountry()
        countryPicker.setSelectedCountryName(userCountry, animated: false)
        return countryPicker
    }
    
    /// UIDatePicker with .Date preselected mode and pre-set time: 28 March 1987 (default) or user's birthday
    func defatultDatePicker() -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Date
        let userBirthday = (birthday != nil) ? birthday : Profile.defaultBirthday()
        datePicker.setDate(userBirthday!, animated: false)
        return datePicker
    }
    
    /// Should be a singleton -> refactor
    lazy var shortDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter
    }()
}