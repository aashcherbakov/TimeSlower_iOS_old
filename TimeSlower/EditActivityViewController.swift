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
            var indexes = [NSIndexPath]()
            
            if let expandedCellIndex = expandedCellIndex, newValue = newValue where newValue != expandedCellIndex {
                indexes = [expandedCellIndex, newValue]
            } else if let newValue = newValue {
                indexes = [newValue]
            } else if let expandedCellIndex = expandedCellIndex {
                indexes = [expandedCellIndex]
            }
            
            tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    var userProfile: Profile?
    var activity: Activity?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    
    private func editDurationCell(fromTableView tableView: UITableView) -> EditDurationCell {
        let cell: EditDurationCell = tableView.dequeueReusableCell()
        
        let signal = cell.control.rac_signalForControlEvents(.ValueChanged)
            .toSignalProducer()
            .map { (slider) -> Int? in
                if let slider = slider as? EditActivityDurationView {
                    return slider.value
                }
                return nil
            }
            .startWithNext { [weak self] (duration) in
                print(duration)
        }
        
        return cell
    }
    
    private func editBasisCell(fromTableView tableView: UITableView) -> EditBasisCell {
        let cell: EditBasisCell = tableView.dequeueReusableCell()
        
        let signal = cell.control.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [weak self] (_) in
            if let indexPath = tableView.indexPathForCell(cell) {
                self?.expandedCellIndex = indexPath
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
        
        return cell
    }
    

}

// MARK: - UITableViewDelegate
extension EditActivityVC: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is ExpandableCell {
            expandedCellIndex = indexPath
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let selectedRow = EditRow(rawValue: indexPath.row) else { return 0 }
        
        if let expandableType = selectedRow.expandableCellType() {
            if indexPath == expandedCellIndex {
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
        case 0:
            return EditNameCell()
        case 1:
            return editBasisCell(fromTableView: tableView)
        default:
            return UITableViewCell()
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

class EditNameCell: UITableViewCell, ObservableControlCell, ExpandableCell {
    weak var control: UIControl!
    static let expandedHeight: CGFloat = 160
    static let defaultHeight: CGFloat = 50
}