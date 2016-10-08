//
//  ProfileEditingDataSource.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

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

/// Protocol that is used to pass data of specified CellType to delegate
protocol ProfileEditingCellDelegate: class {
    func profileEditingCellDidUpdateValue(value: String, type: ProfileEditingCellType)
}

/// Protocol that notifies view controller that some data is entered
protocol ProfileEditingDataSourceDelegate: class {
    func profileEditingDataSourceDidUpdateValue()
}

/// DataSource responsible for providing data to ProfileEditing view controller
class ProfileEditingDataSource: NSObject {
    
    fileprivate weak var tableView: UITableView!
    fileprivate weak var delegate: ProfileEditingDataSourceDelegate?

    fileprivate var name: String?
    fileprivate var country: String?
    fileprivate var birthday: String?
    
    var image: UIImage?
    var gender: Gender?
    
    fileprivate let rowStructure: [ProfileEditingCell.Type] = [
        ProfileNameCell.self,
        ProfileBirthdayCell.self,
        ProfileCountryCell.self
    ]
    
    private var dataStore = DataStore()
    
    init(withTableView tableView: UITableView, delegate: ProfileEditingDataSourceDelegate) {
        self.delegate = delegate
        self.tableView = tableView
        super.init()
        registerCells()
    }
    
    func saveProfile() {
        if let profile = fetchProfile() {
            let _: Profile = dataStore.update(profile)
        } else {
            if let profile = newProfile(fromProfile: nil) {
                dataStore.create(profile)
            }
        }
    }
    
    private func newProfile(fromProfile profile: Profile?) -> Profile? {
        guard
            let name = name, let country = country, let birthday = birthday, let gender = gender,
            let dateOfBirth = StaticDateFormatter.shortDateAndTimeFormatter.date(from: birthday)
        else {
            return nil
        }
        
        let updatedProfile = Profile(
            name: name,
            country: country,
            dateOfBirth: dateOfBirth,
            gender: gender,
            maxAge: profile != nil ? profile!.maxAge : 0,
            photo: image,
            resourceId: profile != nil ? profile!.resourceId : nil)
        
        return updatedProfile
    }
    
    private func fetchProfile() -> Profile? {
        let profile: Profile? = dataStore.retrieve("")
        return profile
    }
    
    func profileHasNoActivities() -> Bool {
        return true
    }
    
    /// Convenience method to check number of rows from ViewController
    ///
    /// - returns: number of items in rowStructure
    func numberOfRows() -> Int {
        return rowStructure.count
    }
    
    /// Checks if user did not enter one of required fields
    ///
    /// - returns: String for field that is missing or nil
    func missingData() -> String? {
        guard let _ = name else { return "Name" }
        guard let _ = country else { return "Country" }
        guard let _ = birthday else { return "Birthday" }
        guard let _ = gender else { return "Gender" }
        
        return nil
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: ProfileNameCell.className, bundle: nil),
                           forCellReuseIdentifier: ProfileNameCell.className)
        tableView.register(UINib(nibName: ProfileBirthdayCell.className, bundle: nil),
                           forCellReuseIdentifier: ProfileBirthdayCell.className)
        tableView.register(UINib(nibName: ProfileCountryCell.className, bundle: nil),
                           forCellReuseIdentifier: ProfileCountryCell.className)
    }
    
    fileprivate func configuration(forType type: ProfileEditingCell.Type) -> TextfieldConfiguration {
        
        switch type {
        case is ProfileNameCell.Type: return ProfileNameTextfield()
        case is ProfileBirthdayCell.Type: return ProfileBirthdayTextfield()
        case is ProfileCountryCell.Type: return ProfileCountryTextfield()
        default: fatalError("Unknown cell type request")
        }
    }
}

// MARK: - ProfileEditingCellDelegate
extension ProfileEditingDataSource: ProfileEditingCellDelegate {
    func profileEditingCellDidUpdateValue(value: String, type: ProfileEditingCellType) {
        switch type {
        case .Name: name = value
        case .Birthday: birthday = value
        case .Country: country = value
        }
        
        delegate?.profileEditingDataSourceDidUpdateValue()
    }
}

// MARK: - UITableViewDataSource
extension ProfileEditingDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < rowStructure.count else { return UITableViewCell() }

        let cellType = rowStructure[indexPath.row]
        let identifier = String(describing: cellType)
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier, for: indexPath) as? ProfileEditingCell {
           
            setupCell(cell, type: cellType)
            return cell as! UITableViewCell
        }
        
        return UITableViewCell()
    }
    
    func setupCell(_ cell: ProfileEditingCell, type: ProfileEditingCell.Type) {
        let config = configuration(forType: type)
        cell.setup(withConfiguration: config)
        cell.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowStructure.count
    }
    
}
