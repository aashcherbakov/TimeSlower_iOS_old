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
    
    typealias BasisToDisplay = ActivitiesList.BasisToDisplay
    
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
    }
    
    func updateData() {
        loadData()
    }
    
    /// Displays activities of selected basis, reload table view
    ///
    /// - parameter basis: BasisToDisplay
    func displayActivities(forBasis basis: BasisToDisplay) {
        basisToDisplay = basis
        tableView.reloadData()
    }
    
    func delete(activity: Activity) {
        removeActivityFromAllLists(activity: activity)
        // TODO: delete results for activity
        NotificationScheduler().cancelNotification(forActivity: activity, notificationType: .Start)
        NotificationScheduler().cancelNotification(forActivity: activity, notificationType: .Finish)
        dataStore.delete(activity)
    }
    
    // MARK: - Private Functions
    
    private func loadData() {
        allActivities = dataStore.activities(forDate: nil, type: .routine)
        activitiesForToday = findActivitiesForToday()
        tableView.reloadData()
    }
    
    private func findActivitiesForToday() -> [Activity] {
        let weekday = Weekday.createFromDate(Date())
        return allActivities?.filter { $0.days.contains(weekday) } ?? []
    }
    
    private func removeActivityFromAllLists(activity: Activity) {
        allActivities = allActivities?.filter { $0.resourceId != activity.resourceId }
        activitiesForToday = activitiesForToday?.filter { $0.resourceId != activity.resourceId }
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StandardActivityCell, let activity = cell.activity {
            tableView.beginUpdates()
            delete(activity: activity)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.endUpdates()
        }
    }
}
