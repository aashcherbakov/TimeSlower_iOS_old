//
//  ProfileEditingViewModel.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 11/8/15.
//  Copyright © 2015 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit
import RxSwift
import RxCocoa

class ProfileEditingViewModel : NSObject {
    
    private struct Constants {
        static let defaultCellHeight: CGFloat = 50
        static let expandedCellHeight: CGFloat = 220
        static let numberOfCells: Int = 3
    }
    
    private(set) var tableView: UITableView
    private(set) var profile: Profile?
    
    private var selectedIndexPath: NSIndexPath?
    private(set) var cellConfig: ProfileEditingCellConfig?
    private(set) var selectedGender: Profile.Gender?
    private(set) var selectedAvatar: UIImage?
    
    init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        self.setupData()
        self.setupEvents()
        self.setupDesign()
    }
    
    // MARK: - Internal Functions
    
    /// [tested] Sets selected user gender private property to Profile.Gender type value
    func userDidPickGender(intValue: Int) {
        self.selectedGender = Profile.Gender(rawValue: intValue)
    }
    
    /// Sets selected image as an avatar
    func userDidPickAvatar(image: UIImage) {
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
        guard let name = cellConfig?.name, birthday = cellConfig?.birthday,
            country = cellConfig?.country, gender = selectedGender else { return }
        
        Profile.saveProfile(withName: name, birthday: birthday, country: country,
            avatar: selectedAvatar, gender: gender)
    }
    
    func reloadTableView() {
        selectedIndexPath = nil
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Private Functions
    
    private func setupData() {
        profile = CoreDataStack.sharedInstance.fetchProfile()
        cellConfig = ProfileEditingCellConfig(withProfile: profile)
        
        if let profile = profile {
            selectedAvatar = UIImage(data: profile.photo)
            selectedGender = profile.userGender()
        }
    }
    
    private func setupEvents() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func setupDesign() {
        self.tableView.registerNib(UINib(nibName: ProfileEditingTableViewCell.className, bundle: nil),
            forCellReuseIdentifier: ProfileEditingTableViewCell.className)
    }
    
    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> ProfileEditingCellType? {
        switch indexPath.row {
        case 0: return .Name
        case 1: return .Birthday
        case 2: return .Country
        default: return nil
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileEditingViewModel : UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellType = cellTypeForIndexPath(indexPath) else { return UITableViewCell() }
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(ProfileEditingTableViewCell.className)
            as? ProfileEditingTableViewCell {
                if let config = cellConfig {
                    cell.setupWith(type: cellType, config: config)
                }
                return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfCells
    }
}

// MARK: - UITableViewDelegate

extension ProfileEditingViewModel : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let expanded = selectedIndexPath != indexPath
        
        resetCellAtIndexPath(selectedIndexPath, inTableView: tableView)
        if selectedIndexPath != indexPath {
            resetCellAtIndexPath(indexPath, inTableView: tableView)
        }
        
        selectedIndexPath = (indexPath != selectedIndexPath) ? indexPath : nil
        
        if let expandableCell = tableView.cellForRowAtIndexPath(indexPath) as? ProfileEditingTableViewCell {
            if expandableCell.shouldExpand() {
                tableView.beginUpdates()
                expandableCell.setExpended(expanded)
                tableView.endUpdates()
            }
        }
    }
    
    private func resetCellAtIndexPath(indexPath: NSIndexPath?, inTableView tableView: UITableView) {
        guard let path = indexPath else { return }
        
        if let cell = tableView.cellForRowAtIndexPath(path) as? ProfileEditingTableViewCell {
            cell.setExpended(false)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if selectedIndexPath == indexPath {
            return Constants.expandedCellHeight
        } else if selectedIndexPath == nil {
            return Constants.defaultCellHeight
        } else {
            return 0
        }
    }
}