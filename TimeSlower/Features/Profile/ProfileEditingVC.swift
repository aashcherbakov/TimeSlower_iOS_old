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
            postAlertOnLackOfInfo(message: reason)
        } else {
            viewModel?.saveProfile()
            dismissViewControllerAnimated(true, completion: nil)
        }
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
        avatarImage.layer.cornerRadius = avatarImage.bounds.height / 2
        avatarImage.clipsToBounds = true
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
