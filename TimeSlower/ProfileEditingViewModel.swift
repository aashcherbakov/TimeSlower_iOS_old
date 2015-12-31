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
        static let expandedCellHeight: CGFloat = 200
        static let numberOfCells: Int = 3
    }
    
    private(set) var tableView: UITableView
    private(set) var profile: Profile? = CoreDataStack.sharedInstance.fetchProfile()
    private var selectedIndexPath: NSIndexPath?
    private var cellConfig = ProfileEditingCellConfig(withProfile: nil)
    
    // Profile properties
    var gender: Profile.Gender?
    var userImage: UIImage?
    var userName: String?
    var userBirthday: NSDate?
    var userCountry: String?
    
    init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        self.setupData()
        self.setupEvents()
        self.setupDesign()
    }
    
    private func setupData() {
        if let existingProfile = self.profile {
            self.gender = existingProfile.userGender()
            self.userBirthday = existingProfile.birthday
            self.userCountry = existingProfile.country
            self.userName = existingProfile.name
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

extension ProfileEditingViewModel : UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellType = cellTypeForIndexPath(indexPath) else { return UITableViewCell() }
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(ProfileEditingTableViewCell.className)
            as? ProfileEditingTableViewCell {
                cell.setupWith(type: cellType, config: self.cellConfig)
                return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfCells
    }
}

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
        } else {
            return Constants.defaultCellHeight
        }
    }
}