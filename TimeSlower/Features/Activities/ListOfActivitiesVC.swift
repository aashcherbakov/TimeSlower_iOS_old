//
//  ListOfActivitiesVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/5/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit

class ListOfActivitiesVC: ListOfActivitiesVCConstraints {

    enum TypeToDisplay: Int {
        case routines
        case goals
        case bothTypes
    }
    
    enum BasisToDisplay: Int {
        case today
        case fullList
    }
    
    struct Constants {
        static let createActivitySegue = "Create New Activity"
    }
    
    @IBOutlet weak var typeSelector: TypeSelector!
    @IBOutlet weak var listTypeSelector: ListTypeSelector!
    @IBOutlet weak var createActivityButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var presentedModally = false
    var typeToDisplay: TypeToDisplay = .bothTypes
    var basisToDisplay: BasisToDisplay = .today
    var profile: Profile! { didSet { getherActivitiesToDisplay() } }
    var activitiesToDisplay:[Activity]! {
        didSet {
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        if profile != nil {
            getherActivitiesToDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        typeSelector.addTarget(self, action: #selector(ListOfActivitiesVC.typeDidChange(_:)), for: .valueChanged)
        listTypeSelector.addTarget(self, action: #selector(ListOfActivitiesVC.basisDidChange(_:)), for: .valueChanged)
        createActivityButton.layer.cornerRadius = buttonHeight.constant / 2
        navigationController?.delegate = nil
        setupTable()
        getherActivitiesToDisplay()
        tableView.reloadData()
    }
    
    
    
    func setupTable() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
    }
    
    //MARK: - Populate table
    
    func getherActivitiesToDisplay() {
        activitiesToDisplay = filterActivitiesByType(typeToDisplay, activities: activitiesForBasis(basisToDisplay))
        if tableView != nil { tableView.reloadData() }
    }
    
    func filterActivitiesByType(_ type: TypeToDisplay, activities: [Activity]) -> [Activity] {
        if type == .bothTypes {
            return activities
        } else {
            let matchingType: ActivityType = (type == .routines) ? .routine : .goal
            return activities.filter { (activity) in activity.activityType() == matchingType }
        }
    }
    
    func activitiesForBasis(_ basis: BasisToDisplay) -> [Activity] {
        return basis == .today ? profile.activitiesForDate(Date()) : profile.allActivities()
    }
    
    //MARK: - Actions
    
    func typeDidChange(_ sender: TypeSelector) {
        if let selectedIndex = sender.selectedSegmentIndex {
            typeToDisplay = TypeToDisplay(rawValue: selectedIndex)!
        } else {
            typeToDisplay = .bothTypes
        }
        getherActivitiesToDisplay()
    }
    
    func basisDidChange(_ sender: ListTypeSelector) {
        basisToDisplay = BasisToDisplay(rawValue: sender.selectedSegmentIndex!)!
        getherActivitiesToDisplay()
    }
    
    @IBAction func onEditButton(_ sender: UIButton) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func onCreateActivityButton(_ sender: AnyObject) {
        let createActivityVC: EditActivityVC = ControllerFactory.createController()
        createActivityVC.userProfile = profile
        navigationController?.pushViewController(createActivityVC, animated: true)
    }
    // MARK: - Navigation
    
    @IBAction func onBackButton(_ sender: UIButton) {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        }
        
        if presentedModally {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func saveActivityReturnToList(_ segue: UIStoryboardSegue) {
    
    }
    
    @IBAction func backToActivityList(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ActivityStats" {
            if let vc = segue.destination as? ActivityStatsVC {
                if let cell = sender as? StandardActivityCell {
                    vc.activity = cell.activity
                }
            }
        }
        
        if segue.identifier == Constants.createActivitySegue {
            if let vc = segue.destination as? EditActivityVC {
                vc.userProfile = self.profile
            }
        }
    }
}


// MARK: - Table view data source
extension ListOfActivitiesVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profile != nil ? activitiesToDisplay.count : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? StandardActivityCell {
            let editActivityVC: EditActivityVC = ControllerFactory.createController()
            editActivityVC.activity = cell.activity
            navigationController?.pushViewController(editActivityVC, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! StandardActivityCell
        cell.activity = activitiesToDisplay[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        let activityToDelete = activitiesToDisplay[(indexPath as NSIndexPath).row]
        activitiesToDisplay.remove(at: (indexPath as NSIndexPath).row)
        CoreDataStack.sharedInstance.managedObjectContext?.delete(activityToDelete)
        CoreDataStack.sharedInstance.saveContext()
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }
}
