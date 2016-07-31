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
import RxSwift
import RxCocoa
import TimeSlowerKit

class ProfileEditingVC: ProfileEditingVCConstraints {
    
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var propertiesTableView: UITableView!
    @IBOutlet weak var genderSelector: GenderSelector!
    
    var viewModel: ProfileEditingViewModel?
    private var disposable = DisposeBag()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel = ProfileEditingViewModel(withTableView: self.propertiesTableView)
        
        if let selectedGenderValue = viewModel?.selectedGender?.rawValue {
            genderSelector.setSelectedGender(selectedGenderValue)
        }
        
        if let avatar = viewModel?.selectedAvatar {
            avatarImage.image = avatar
            setupImageViewForAvatar()
        }
        
        genderSelector.rx_controlEvents(.ValueChanged)
            .subscribeNext { [weak self] (value) -> Void in
                if let index = self?.genderSelector.selectedSegmentIndex {
                    self?.viewModel?.userDidPickGender(index)
                }
            }
            .addDisposableTo(disposable)
    }
    
    //MARK: - ACTIONS

    @IBAction func onSaveButton() {
        if let reason = viewModel?.userDidMissData() {
            viewModel?.reloadTableView()
            postAlertOnLackOfInfo(message: reason)
        } else {
            viewModel?.saveProfile()
            if viewModel?.profile?.activities.count == 0 {
                createFirstActivity()
            } else {
                dismissController()
            }
        }
    }
    
    private func createFirstActivity() {
        let activityController: EditActivityVC = ControllerFactory.createController()
        activityController.userProfile = viewModel?.profile
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    @IBAction func avatarButtonPressed() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let photoPicker = UIImagePickerController()
            photoPicker.sourceType = .PhotoLibrary
            photoPicker.delegate = self
            photoPicker.allowsEditing = true
            presentViewController(photoPicker, animated: true, completion: nil)
        }
    }
    
    func postAlertOnLackOfInfo(message message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func setupImageViewForAvatar() {
        avatarImage.contentMode = .ScaleAspectFit
        avatarImage.layer.cornerRadius = (avatarViewHeight.constant - 18) / 2
        avatarImage.clipsToBounds = true
    }
    
    private func dismissController() {
        if navigationController != nil {
            navigationController?.popViewControllerAnimated(true)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension ProfileEditingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        
        if let selectedImage = image {
            setupImageViewForAvatar()
            avatarImage.image = selectedImage
            viewModel?.userDidPickAvatar(selectedImage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
