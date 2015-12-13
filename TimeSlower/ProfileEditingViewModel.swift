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
    
    private(set) var tableView: UITableView
    private(set) var profile: Profile? = CoreDataStack.sharedInstance.fetchProfile()
    
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
}

extension ProfileEditingViewModel : UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellType: ProfileEditingCellType!
        
        switch indexPath.row {
        case 0: cellType = .Name
        case 1: cellType = .Birthday
        case 2: cellType = .Country
        default: break
        }
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(ProfileEditingTableViewCell.className) as? ProfileEditingTableViewCell {
            cell.setupWith(type: cellType)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

extension ProfileEditingViewModel : UITableViewDelegate {
    
}