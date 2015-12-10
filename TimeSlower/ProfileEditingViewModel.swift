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
}

extension ProfileEditingViewModel : UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}

extension ProfileEditingViewModel : UITableViewDelegate {
    
}