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

    struct Constants {
        static let defaultDateLabelText = "Select your birthday date"
        static let defaultCountryLabelText = "Select your country"
        
        //segues
        static let returnToMainVCSegue = "ProfileCreated"
        static let changesSaved = "SaveProfileAndReturnToProfileStats"
    }
    
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var propertiesTableView: UITableView!
    
    var viewModel: ProfileEditingViewModel?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        self.viewModel = ProfileEditingViewModel(withTableView: self.propertiesTableView)
    }
    
    //MARK: - ACTIONS

    @IBAction func onSaveButton() {
        if currentEditingState == .Default {
            if savingIsPossible().0 {
                saveProfile()
                let segueID = presentingViewController!.isKindOfClass(ProfileStatsVC) ?
                    Constants.changesSaved : Constants.returnToMainVCSegue
                performSegueWithIdentifier(segueID, sender: self)
            } else {
                postAlertOnLackOfInfo(message: savingIsPossible().1)
            }
        } else {
            currentEditingState = .Default
        }
    }
    
    @IBAction func avatarButtonPressed() {
        currentEditingState = .Default
        
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
    
    func savingIsPossible() -> (Bool, String) {
//        if nameTextField.text == "" {
//            return (false, "Please, enter your name")
//        }
//        if selectedGender == nil {
//            return (false, "Please, select your gender")
//        }
//        if birthdayLabel.text == Constants.defaultDateLabelText {
//            return (false, "Please, select your birthday date")
//        }
//        if countryLabel.text == Constants.defaultCountryLabelText {
//            return (false, "Please, select your country")
//        }
        return (true, "")
    }
    
    func saveProfile() {
//        if userProfile == nil {
//            let context = CoreDataStack.sharedInstance.managedObjectContext
//            userProfile = Profile.userProfileInManagedContext(context!)
//        }
////        userProfile.name = nameTextField.text!
////        userProfile.birthday = dateFormatter.dateFromString(birthdayLabel.text!)!
////        userProfile.country = countryLabel.text!
//        userProfile.gender = Profile.genderWithEnum(selectedGender!)
//        if avatarImage.image != UIImage(named: "avatarPickerImage") {
//            userProfile.photo = UIImagePNGRepresentation(avatarImage.image!)!
//        } else {
//            userProfile.photo = UIImagePNGRepresentation(UIImage(named: "defaultUserImage")!)!
//        }
//        userProfile.saveChangesToCoreData()
    }
    
    
    // MARK: - Lazy instantiation

    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()
    
    func setupImageViewForAvatar() {
        avatarImage.contentMode = .ScaleAspectFit
        avatarImage.layer.cornerRadius = avatarImage.bounds.height / 2
        avatarImage.clipsToBounds = true
    }
}

extension ProfileEditingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        setupImageViewForAvatar()
        avatarImage.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
