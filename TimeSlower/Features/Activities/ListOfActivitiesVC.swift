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
    
    @IBOutlet weak var listTypeSelector: ListTypeSelector!
    @IBOutlet weak var createActivityButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var presentedModally = false
    var typeToDisplay: TypeToDisplay = .bothTypes
    var basisToDisplay: BasisToDisplay = .today
    
    fileprivate var dataSource: ListOfActivitiesDataSource!
    
    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: implement delegate to avoid reloading data on each appearance
        dataSource.updateData()
        dataSource.displayActivities(forBasis: basisToDisplay)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDesign()
        setupData()
        setupEvents()
    }
    
    //MARK: - Actions
    
    func basisDidChange(_ sender: ListTypeSelector) {
        if let basis = BasisToDisplay(rawValue: sender.selectedSegmentIndex) {
            basisToDisplay = basis
            dataSource.displayActivities(forBasis: basis)
        }
    }
    
    @IBAction func onBackButton(_ sender: UIButton) {
        dismissViewController()
    }
    
    @IBAction func onEditButton(_ sender: UIButton) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func onCreateActivityButton(_ sender: AnyObject) {
        showEditActivityVC()
    }

    // MARK: - Private Functions
    
    private func setupData() {
        dataSource = ListOfActivitiesDataSource(withTableView: tableView)
        dataSource.displayActivities(forBasis: basisToDisplay)
    }
    
    private func setupEvents() {
        listTypeSelector.addTarget(self, action: #selector(ListOfActivitiesVC.basisDidChange(_:)), for: .valueChanged)
    }
    
    private func setupDesign() {
        navigationController?.isNavigationBarHidden = true
        createActivityButton.layer.cornerRadius = buttonHeight.constant / 2
        navigationController?.delegate = nil
        setupTableViewDesign()
    }
    
    private func setupTableViewDesign() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
    }
    
    // MARK: - Navigation
    
    private func showEditActivityVC() {
        let createActivityVC: EditActivityVC = ControllerFactory.createController()
        navigationController?.pushViewController(createActivityVC, animated: true)
    }
    
    private func dismissViewController() {
        if navigationController != nil {
            let _ = navigationController?.popViewController(animated: true)
        }
        
        if presentedModally {
            dismiss(animated: true, completion: nil)
        }
    }
    
}


// MARK: - Table view data source
extension ListOfActivitiesVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? StandardActivityCell {
            
            let statsVC: ActivityStatsVC = ControllerFactory.createController()
            statsVC.activity = cell.activity
            navigationController?.pushViewController(statsVC, animated: true)
        }
    }

    

}
