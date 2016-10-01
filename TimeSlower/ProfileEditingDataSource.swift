//
//  ProfileEditingDataSource.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit


/// DataSource responsible for providing data to ProfileEditing view controller
class ProfileEditingDataSource: NSObject {
    
    private weak var tableView: UITableView!
    
    fileprivate let rowStructure: [ProfileEditingCell.Type] = [
        ProfileNameCell.self, ProfileBirthdayCell.self, ProfileCountryCell.self
    ]
    
    init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        registerCells()
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: ProfileNameCell.className, bundle: nil), forCellReuseIdentifier: ProfileNameCell.className)
        tableView.register(UINib(nibName: ProfileBirthdayCell.className, bundle: nil), forCellReuseIdentifier: ProfileBirthdayCell.className)
        tableView.register(UINib(nibName: ProfileCountryCell.className, bundle: nil), forCellReuseIdentifier: ProfileCountryCell.className)
    }
    
    fileprivate func configuration(forType type: ProfileEditingCell.Type) -> TextfieldConfiguration? {
        
        switch type {
        case is ProfileNameCell.Type: return ProfileNameTextfield()
        case is ProfileBirthdayCell.Type: return ProfileBirthdayTextfield()
        case is ProfileCountryCell.Type: return ProfileCountryTextfield()
        default: return nil
        }
    }
}

// MARK: - UITableViewDataSource
extension ProfileEditingDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row < rowStructure.count else {
            return UITableViewCell()
        }
        
        let cellType = rowStructure[indexPath.row]
        let identifier = String(describing: cellType)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ProfileEditingCell {
            
            if let config = configuration(forType: cellType) {
                cell.setup(withConfiguration: config)
            }
            
            return cell as! UITableViewCell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowStructure.count
    }
    
}
