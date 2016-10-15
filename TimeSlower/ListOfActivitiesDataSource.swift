//
//  ListOfActivitiesDataSource.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 10/15/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import TimeSlowerKit

internal final class ListOfActivitiesDataSource: NSObject {
    
    typealias BasisToDisplay = ListOfActivitiesVC.BasisToDisplay
    
    fileprivate struct Constants {
        static let defaultCellIdentifier = "ActivityCell"
    }
    
    private weak var tableView: UITableView!
    private var dataStore: DataStore
    
    private(set) var activitiesForToday: [Activity]?
    private(set) var allActivities: [Activity]?
    
    private(set) var basisToDisplay: BasisToDisplay?
    
    
    init(withTableView tableView: UITableView, dataStore: DataStore = DataStore()) {
        self.tableView = tableView
        self.dataStore = dataStore
        
        super.init()
        
        tableView.dataSource = self
        
        loadData()
    }
    
    func displayActivities(forBasis basis: BasisToDisplay) {
        basisToDisplay = basis
        tableView.reloadData()
    }
    
    private func loadData() {
        allActivities = dataStore.activities(forDate: nil, type: .routine)
        activitiesForToday = findActivitiesForToday()
        tableView.reloadData()
    }
    
    private func findActivitiesForToday() -> [Activity] {
        let weekday = Weekday.createFromDate(Date())
        
        if let activities = allActivities {
            return activities.filter { $0.days.contains(weekday) }
        }
        
        return []
    }
    
    fileprivate func activitiesForBasis(basis: BasisToDisplay) -> [Activity] {
        switch basis {
        case .fullList: return allActivities ?? []
        case .today: return allActivities ?? []
        }
    }
}

// MARK: - UITableViewDataSource
extension ListOfActivitiesDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let basis = basisToDisplay else { return 0 }
        switch basis {
        case .today: return activitiesForToday?.count ?? 0
        case .fullList: return allActivities?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let basis = basisToDisplay, let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.defaultCellIdentifier, for: indexPath) as? StandardActivityCell {
            
            let activitiesToDisplay = activitiesForBasis(basis: basis)
            cell.activity = activitiesToDisplay[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
}
