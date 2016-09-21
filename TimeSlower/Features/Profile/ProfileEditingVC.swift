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
    
    var viewModel: ProfileEditingViewModel?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func bindViewModel() {
        viewModel = ProfileEditingViewModel(withTableView: self.propertiesTableView)
        
        if let selectedGenderValue = viewModel?.selectedGender?.rawValue {
            genderSelector.setSelectedGender(selectedGenderValue)
        }
        
        if let avatar = viewModel?.selectedAvatar {
            avatarImage.image = avatar
            setupImageViewForAvatar()
        }
        
//        genderSelector.rx_controlEvents(.ValueChanged)
//            .subscribeNext { [weak self] (value) -> Void in
//                if let index = self?.genderSelector.selectedSegmentIndex {
//                    self?.viewModel?.userDidPickGender(index)
//                }
//            }
//            .addDisposableTo(disposable)
    }
    
    //MARK: - ACTIONS

    @IBAction func onSaveButton() {
        if let reason = viewModel?.userDidMissData() {
            viewModel?.reloadTableView()
            postAlertOnLackOfInfo(reason)
        } else {
            viewModel?.saveProfile()
//            if viewModel?.profile?.activities.count == 0 {
//                createFirstActivity()
//            } else {
//                dismissController()
//            }
        }
    }
    
    fileprivate func createFirstActivity() {
        let activityController: EditActivityVC = ControllerFactory.createController()
        activityController.userProfile = viewModel?.profile
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func avatarButtonPressed() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let photoPicker = UIImagePickerController()
            photoPicker.sourceType = .photoLibrary
            photoPicker.delegate = self
            photoPicker.allowsEditing = true
            present(photoPicker, animated: true, completion: nil)
        }
    }
    
    func postAlertOnLackOfInfo(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupImageViewForAvatar() {
        avatarImage.contentMode = .scaleAspectFit
        avatarImage.layer.cornerRadius = (avatarViewHeight.constant - 18) / 2
        avatarImage.clipsToBounds = true
    }
    
    fileprivate func dismissController() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ProfileEditingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        
        if let selectedImage = image {
            setupImageViewForAvatar()
            avatarImage.image = selectedImage
            viewModel?.userDidPickAvatar(selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
