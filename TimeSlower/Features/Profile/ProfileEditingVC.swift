//
//  ProfileVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/1/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices
import TimeSlowerKit

class ProfileEditingVC: ProfileEditingVCConstraints {
    
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var propertiesTableView: UITableView!
    @IBOutlet weak var genderSelector: GenderSelector!
    
    private var dataSource: ProfileEditingDataSource?
    
    fileprivate struct Constants {
        static let collapsedCellHeight = 0 as CGFloat
        static let expandedCellHeight = 220 as CGFloat
        static let defaultCellHeight = 50 as CGFloat
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
        propertiesTableView.dataSource = dataSource
        propertiesTableView.delegate = self
        navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - ACTIONS

    @IBAction func onSaveButton() {
    }
    
    @IBAction func avatarButtonPressed() {
        presentPhotoPicker()
    }
    
    fileprivate func createFirstActivity() {
        let activityController: EditActivityVC = ControllerFactory.createController()
        present(activityController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    func postAlertOnLackOfInfo(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func dismissController() {
        if navigationController != nil {
            _ = navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ProfileEditingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedCellIndex != indexPath {
            selectedCellIndex = indexPath
        } else {
            selectedCellIndex = nil
        }
        
        resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
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

extension ProfileEditingVC: ProfileEditingDataSourceDelegate {
    func profileEditingDataSourceDidUpdateValue() {
        if let currentRow = selectedCellIndex?.row, currentRow + 1 < 3 {
            let nextCellIndex = IndexPath(row: currentRow + 1, section: 0)
            propertiesTableView.selectRow(at: nextCellIndex, animated: true, scrollPosition: .middle)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProfileEditingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        
        if let selectedImage = image {
            setupImageViewForAvatar()
            avatarImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func presentPhotoPicker() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let photoPicker = UIImagePickerController()
            photoPicker.sourceType = .photoLibrary
            photoPicker.delegate = self
            photoPicker.allowsEditing = true
            present(photoPicker, animated: true, completion: nil)
        }
    }
    
    fileprivate func setupImageViewForAvatar() {
        avatarImage.contentMode = .scaleAspectFit
        avatarImage.layer.cornerRadius = (avatarViewHeight.constant - 18) / 2
        avatarImage.clipsToBounds = true
    }
}
