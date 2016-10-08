//
//  ProfileVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/1/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import MobileCoreServices
import TimeSlowerKit
import ReactiveSwift

class ProfileEditingVC: UIViewController {
    
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var propertiesTableView: UITableView!
    @IBOutlet weak var genderSelector: GenderSelector!
    @IBOutlet weak var avatarFrameView: UIView!
    @IBOutlet weak var avatarInnerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    fileprivate var dataSource: ProfileEditingDataSource?
    fileprivate var avatarPicker: AvatarPicker?

    fileprivate struct Constants {
        static let collapsedCellHeight = 0 as CGFloat
        static let expandedCellHeight = 220 as CGFloat
        static let defaultCellHeight = 50 as CGFloat
        static let headerHeightScale = 0.40 as CGFloat
    }
    
    enum Row: Int {
        case Name
        case Birthday
        case Country
        
        func cellHeight(_ expanded: Bool) -> CGFloat {
            switch self {
            case .Name:
                return Constants.defaultCellHeight 
            case .Birthday, .Country:
                return expanded ? Constants.expandedCellHeight : Constants.defaultCellHeight
            }
        }
    }
    
    fileprivate var selectedCellIndex: IndexPath?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = ProfileEditingDataSource(withTableView: propertiesTableView, delegate: self)
        avatarPicker = AvatarPicker(withDelegate: self)
        
        propertiesTableView.dataSource = dataSource
        propertiesTableView.delegate = self
        navigationController?.isNavigationBarHidden = true
        
        subscribeToGenderSelector()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setCircleFormToAvatarImageView()
        setupHeaderViewHeight()
    }
    
    private func setupHeaderViewHeight() {
        headerViewHeight.constant = ScreenHight().rawValue * Constants.headerHeightScale
    }
    
    private func setCircleFormToAvatarImageView() {
        avatarFrameView.layer.cornerRadius = avatarFrameView.bounds.height / 2
        avatarFrameView.layer.borderWidth = 1.0
        avatarFrameView.layer.borderColor = UIColor.purpleRed().cgColor
        avatarInnerView.layer.cornerRadius = avatarInnerView.bounds.height / 2
    }
    
    private func subscribeToGenderSelector() {
        genderSelector.rac_signal(for: .valueChanged).toSignalProducer().startWithResult { [weak self] (result) in
            if let selector = result.value as? GenderSelector, let value = selector.selectedSegmentIndex, let gender = Gender(rawValue: value) {
                self?.dataSource?.gender = gender
            }
        }
    }
    
    //MARK: - ACTIONS

    @IBAction func onSaveButton() {
        if selectedCellIndex != nil {
            moveToNextCellIfNeeded()
            return
        }
        
        saveProfile()
        moveToCreateActivityIfNeeded()
    }
    
    private func saveProfile() {
        if let missingValue = dataSource?.missingData() {
            postAlertOnLackOfInfo(missingValue)
        } else {
            dataSource?.saveProfile()
        }
    }
    
    private func moveToCreateActivityIfNeeded() {
        if let hasActivities = dataSource?.profileHasNoActivities(), hasActivities == false {
            createFirstActivity()
        } else {
            dismissController()
        }
    }
    
    @IBAction func avatarButtonPressed() {
        presentPhotoPicker()
    }
    
    // MARK: - Navigation
    
    fileprivate func postAlertOnLackOfInfo(_ message: String) {
        let alertText = "Oops, some data is missing: \"\(message)\""
        let alert = UIAlertController(title: "Error", message: alertText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func presentPhotoPicker() {
        if let imagePicker = avatarPicker?.photoPicker() {
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    fileprivate func createFirstActivity() {
        let activityController: EditActivityVC = ControllerFactory.createController()
        present(activityController, animated: true, completion: nil)
    }
    
    fileprivate func dismissController() {
        if navigationController != nil {
            _ = navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func setupImageViewForAvatar() {
        avatarImage.contentMode = .scaleAspectFit
        avatarImage.layer.cornerRadius = (avatarFrameView.bounds.height - 18) / 2
        avatarImage.clipsToBounds = true
    }

    // MARK: - TableView update
    
    fileprivate func updateTableViewLayout() {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.propertiesTableView.beginUpdates()
            self.propertiesTableView.endUpdates()
        }
    }
    
    private func setDefaultValue(forCellAtIndex index: IndexPath?) {
        if let index = index, let cell = propertiesTableView.cellForRow(at: index) as? ProfileEditingCell {
            cell.setDefaultValue()
        }
    }
    
    fileprivate func saveValueInCell(forIndexPath indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = propertiesTableView.cellForRow(at: indexPath) as? ProfileEditingCell {
            cell.saveValue()
        }
    }
    
    fileprivate func moveToNextCellIfNeeded() {
        guard let dataSource = dataSource else { return }
        
        if let _ = dataSource.missingData() {
            saveValueInCell(forIndexPath: selectedCellIndex)
        } else {
            selectedCellIndex = nil
            updateTableViewLayout()
        }
    }
    
    fileprivate func moveToNextCell() {
        selectedCellIndex = nextRowIndex(fromSelectedIndex: selectedCellIndex)
        setDefaultValue(forCellAtIndex: selectedCellIndex)
        updateTableViewLayout()
    }
    
    fileprivate func focusOn(cellInPath indexPath: IndexPath?) {
        if selectedCellIndex != indexPath {
            selectedCellIndex = indexPath
        } else {
            selectedCellIndex = nil
        }
        
        resignFirstResponder()
        updateTableViewLayout()
    }
    
    // MARK: - Private

    private func nextRowIndex(fromSelectedIndex currentIndex: IndexPath?) -> IndexPath? {
        guard let totalRows = dataSource?.numberOfRows(), let currentIndex = currentIndex else {
            return nil
        }

        let nextRow = currentIndex.row + 1
        return nextRow < totalRows ? IndexPath(row: nextRow, section: 0) : nil
    }

}

// MARK: - ProfileEditingDataSourceDelegate
extension ProfileEditingVC: ProfileEditingDataSourceDelegate {
    func profileEditingDataSourceDidUpdateValue() {
        moveToNextCell()
    }
}

// MARK: - UITableViewDelegate
extension ProfileEditingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        focusOn(cellInPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let row = Row(rawValue: indexPath.row) else {
            return Constants.collapsedCellHeight
        }
        
        if selectedCellIndex == nil {
            return Constants.defaultCellHeight
        } else if selectedCellIndex == indexPath {
            return row.cellHeight(true)
        } else {
            return Constants.collapsedCellHeight
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProfileEditingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = avatarPicker?.image(fromInfo: info) {
            setupImageViewForAvatar()
            avatarImage.image = selectedImage
            dataSource?.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
