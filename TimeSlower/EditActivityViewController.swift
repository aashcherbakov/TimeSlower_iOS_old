//
//  EditActivityViewController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/30/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import ReactiveCocoa
import TimeSlowerKit

protocol ObservableControlCell {
    weak var control: UIControl! { get }
}

protocol ExpandableCell {
    static var expandedHeight: CGFloat { get }
    static var defaultHeight: CGFloat { get }
}

class EditActivityVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var name: String?
    
    var expandedCellIndex: NSIndexPath? {
        willSet {
            UIView.animateWithDuration(0.3) { 
                self.tableView.beginUpdates()
                self.lastExpandedCellIndex = newValue
                self.tableView.endUpdates()
            }
        }
    }
    
    var lastExpandedCellIndex: NSIndexPath?
    
    var userProfile: Profile?
    var activity: Activity?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    private func editNameCellFromTableView(tableView: UITableView) -> EditNameCell {
        let cell: EditNameCell = tableView.dequeueReusableCell()

        cell.control.rac_signalForControlEvents(.TouchUpInside).toSignalProducer()
            .observeOn(UIScheduler())
            .startWithNext { [weak self] (_) in
                self?.expandedCellIndex = tableView.indexPathForCell(cell)
        }
        
        return cell
    }

    
    private func editBasisCell(fromTableView tableView: UITableView) -> EditBasisCell {
        let cell: EditBasisCell = tableView.dequeueReusableCell()
        
        cell.control.rac_signalForControlEvents(.TouchUpInside).toSignalProducer()
            .observeOn(UIScheduler())
            .startWithNext {
                [weak self] (_) in
                self?.expandCell(cell, inTableView: tableView)
                print("Basis cell to expand")
        }
        
        return cell
    }
    
    private func expandCell(cell: UITableViewCell, inTableView tableView: UITableView) {
        guard let indexPath = tableView.indexPathForCell(cell) else { return }
        expandedCellIndex = indexPath
    }

}

// MARK: - UITableViewDelegate
extension EditActivityVC: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let selectedRow = EditRow(rawValue: indexPath.row) else { return 0 }
        
        if let expandableType = selectedRow.expandableCellType() {
            if indexPath == lastExpandedCellIndex {
                return expandableType.expandedHeight
            } else {
                return expandableType.defaultHeight
            }
        }
        
        return 0
    }
    
    private enum EditRow: Int {
        case Name
        case Basis
        case Duration
        case StartTime
        case Notifications
        case Saving
        
        func expandableCellType() -> ExpandableCell.Type? {
            switch self {
            case Name: return EditNameCell.self
            case Basis: return EditBasisCell.self
            case Duration: return EditDurationCell.self
            default: return nil
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension EditActivityVC: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0: return editNameCellFromTableView(tableView)
        case 1: return editBasisCell(fromTableView: tableView)
        default: return UITableViewCell()
        }
    }
}


class EditDurationCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    @IBOutlet weak var control: UIControl!
    static let expandedHeight: CGFloat = 80
    static let defaultHeight: CGFloat = 50
}

class EditBasisCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    
    @IBOutlet weak var control: UIControl!
    
    static let expandedHeight: CGFloat = 80
    static let defaultHeight: CGFloat = 50

}
