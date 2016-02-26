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
        case Routines
        case Goals
        case BothTypes
    }
    
    enum BasisToDisplay: Int {
        case Today
        case FullList
    }
    
    struct Constants {
        static let createActivitySegue = "Create New Activity"
    }
    
    @IBOutlet weak var typeSelector: TypeSelector!
    @IBOutlet weak var listTypeSelector: ListTypeSelector!
    @IBOutlet weak var createActivityButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var typeToDisplay: TypeToDisplay = .BothTypes
    var basisToDisplay: BasisToDisplay = .Today
    var profile: Profile! { didSet { getherActivitiesToDisplay() } }
    var activitiesToDisplay:[Activity]! {
        didSet {
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    //MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        if profile != nil {
            getherActivitiesToDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        typeSelector.addTarget(self, action: Selector("typeDidChange:"), forControlEvents: .ValueChanged)
        listTypeSelector.addTarget(self, action: Selector("basisDidChange:"), forControlEvents: .ValueChanged)
        createActivityButton.layer.cornerRadius = buttonHeight.constant / 2
        
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
    
    func filterActivitiesByType(type: TypeToDisplay, activities: [Activity]) -> [Activity] {
        if type == .BothTypes {
            return activities
        } else {
            let matchingType: ActivityType = (type == .Routines) ? .Routine : .Goal
            return activities.filter { (activity) in activity.activityType() == matchingType }
        }
    }
    
    func activitiesForBasis(basis: BasisToDisplay) -> [Activity] {
        return basis == .Today ? profile.activitiesForDate(NSDate()) : profile.allActivities()
    }
    
    //MARK: - Actions
    
    func typeDidChange(sender: TypeSelector) {
        if let selectedIndex = sender.selectedSegmentIndex {
            typeToDisplay = TypeToDisplay(rawValue: selectedIndex)!
        } else {
            typeToDisplay = .BothTypes
        }
        getherActivitiesToDisplay()
    }
    
    func basisDidChange(sender: ListTypeSelector) {
        basisToDisplay = BasisToDisplay(rawValue: sender.selectedSegmentIndex!)!
        getherActivitiesToDisplay()
    }
    
    @IBAction func onEditButton(sender: UIButton) {
        tableView.setEditing(!tableView.editing, animated: true)
    }
    
    // MARK: - Navigation
    
    @IBAction func onBackButton(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveActivityReturnToList(segue: UIStoryboardSegue) {
    
    }
    
    @IBAction func backToActivityList(segue: UIStoryboardSegue) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ActivityStats" {
            if let vc = segue.destinationViewController as? ActivityStatsVC {
                if let cell = sender as? StandardActivityCell {
                    vc.activity = cell.activity
                }
            }
        }
        
        if segue.identifier == Constants.createActivitySegue {
            if let vc = segue.destinationViewController as? EditActivityVC {
                vc.userProfile = self.profile
            }
        }
    }
}


// MARK: - Table view data source
extension ListOfActivitiesVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profile != nil ? activitiesToDisplay.count : 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StandardActivityCell {
            if let editActivityVC = UIStoryboard(name: "Activities", bundle: nil).instantiateViewControllerWithIdentifier(EditActivityVC.className) as? EditActivityVC {
                editActivityVC.activity = cell.activity
                navigationController?.pushViewController(editActivityVC, animated: true)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ActivityCell", forIndexPath: indexPath) as! StandardActivityCell
        cell.activity = activitiesToDisplay[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let activityToDelete = activitiesToDisplay[indexPath.row]
        activitiesToDisplay.removeAtIndex(indexPath.row)
        CoreDataStack.sharedInstance.managedObjectContext?.deleteObject(activityToDelete)
        CoreDataStack.sharedInstance.saveContext()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.endUpdates()
    }
}
