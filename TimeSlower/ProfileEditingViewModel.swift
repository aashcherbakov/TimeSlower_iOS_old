//
//  ProfileEditingViewModel.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 11/8/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

class ProfileEditingViewModel : NSObject {
    
    fileprivate struct Constants {
        static let defaultCellHeight: CGFloat = 50
        static let expandedCellHeight: CGFloat = 220
        static let numberOfCells: Int = 3
    }
    
    fileprivate(set) var tableView: UITableView
    fileprivate(set) var profile: Profile?
    
    fileprivate var selectedIndexPath: IndexPath?
    fileprivate(set) var cellConfig: ProfileEditingCellConfig?
    fileprivate(set) var selectedGender: Profile.Gender?
    fileprivate(set) var selectedAvatar: UIImage?
    
    init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        self.setupData()
        self.setupEvents()
        self.setupDesign()
    }
    
    // MARK: - Internal Functions
    
    /// [tested] Sets selected user gender private property to Profile.Gender type value
    func userDidPickGender(_ intValue: Int) {
        self.selectedGender = Profile.Gender(rawValue: intValue)
    }
    
    /// Sets selected image as an avatar
    func userDidPickAvatar(_ image: UIImage) {
        selectedAvatar = image
    }
    
    /// [tested] Returns String with reason if user did not enter some crusial data
    func userDidMissData() -> String? {
        guard cellConfig?.name != nil else { return "Please, enter your name" }
        guard cellConfig?.country != nil else { return "Please, select your country" }
        guard cellConfig?.birthday != nil else { return "Please, select your birthday date" }
        guard selectedGender != nil else { return "Please, select your gender" }
        
        return nil
    }
    
    /// Method checks if all data is valid and calls Profile class method saveProfile:withName:... 
    func saveProfile() {
        guard let name = cellConfig?.name, let birthday = cellConfig?.birthday,
            let country = cellConfig?.country, let gender = selectedGender else { return }
        
        profile = Profile.saveProfile(withName: name, birthday: birthday, country: country,
            avatar: selectedAvatar, gender: gender)
    }
    
    func reloadTableView() {
        selectedIndexPath = nil
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Private Functions
    
    fileprivate func setupData() {
        profile = CoreDataStack.sharedInstance.fetchProfile()
        cellConfig = ProfileEditingCellConfig(withProfile: profile)
        
        if let profile = profile {
            selectedGender = profile.userGender()
        }
        
        if let photoData = profile?.photo {
            selectedAvatar = UIImage(data: photoData)
        }
    }
    
    fileprivate func setupEvents() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    fileprivate func setupDesign() {
        self.tableView.register(UINib(nibName: ProfileEditingTableViewCell.className, bundle: nil),
            forCellReuseIdentifier: ProfileEditingTableViewCell.className)
    }
    
    fileprivate func cellTypeForIndexPath(_ indexPath: IndexPath) -> ProfileEditingCellType? {
        switch (indexPath as NSIndexPath).row {
        case 0: return .Name
        case 1: return .Birthday
        case 2: return .Country
        default: return nil
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileEditingViewModel : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = cellTypeForIndexPath(indexPath) else { return UITableViewCell() }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ProfileEditingTableViewCell.className)
            as? ProfileEditingTableViewCell {
                if let config = cellConfig {
                    cell.setupWith(cellType, config: config)
                }
                return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfCells
    }
}

// MARK: - UITableViewDelegate

extension ProfileEditingViewModel : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let expanded = selectedIndexPath != indexPath
        
        resetCellAtIndexPath(selectedIndexPath, inTableView: tableView)
        if selectedIndexPath != indexPath {
            resetCellAtIndexPath(indexPath, inTableView: tableView)
        }
        
        selectedIndexPath = (indexPath != selectedIndexPath) ? indexPath : nil
        
        if let expandableCell = tableView.cellForRow(at: indexPath) as? ProfileEditingTableViewCell {
            if expandableCell.shouldExpand() {
                tableView.beginUpdates()
                expandableCell.setExpended(expanded)
                tableView.endUpdates()
            }
        }
    }
    
    fileprivate func resetCellAtIndexPath(_ indexPath: IndexPath?, inTableView tableView: UITableView) {
        guard let path = indexPath else { return }
        
        if let cell = tableView.cellForRow(at: path) as? ProfileEditingTableViewCell {
            cell.setExpended(false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndexPath == indexPath {
            return Constants.expandedCellHeight
        } else if selectedIndexPath == nil {
            return Constants.defaultCellHeight
        } else {
            return 0
        }
    }
}
