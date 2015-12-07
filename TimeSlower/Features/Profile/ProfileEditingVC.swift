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
        
        //image names
        static let nameSelectedIcon = "nameIconSelected"
        static let birthdaySelectedIcon = "birthdayIconSelected"
        static let countrySelectedIcon = "countryIconSelected"
        
        //segues
        static let returnToMainVCSegue = "ProfileCreated"
        static let changesSaved = "SaveProfileAndReturnToProfileStats"
    }
    
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var countryPicker: CountryPicker!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nameIcon: UIImageView!
    @IBOutlet weak var birthdayIcon: UIImageView!
    @IBOutlet weak var countryIcon: UIImageView!
    
    var viewModel: ProfileEditingViewModel?
    
    var userProfile: Profile! 
    var selectedGender: Profile.Gender!
    var selectedBirthday: NSDate! {
        didSet {
            birthdayIcon.image = UIImage(named: Constants.birthdaySelectedIcon)
            birthdayLabel.textColor = UIColor.blackColor()
        }
    }
    var selectedCountry: String! {
        didSet {
            countryIcon.image = UIImage(named: Constants.countrySelectedIcon)
            countryLabel.textColor = UIColor.blackColor()
        }
    }
    var selectedName: String! {
        didSet {
            nameIcon.image = UIImage(named: Constants.nameSelectedIcon)
            nameTextField.textColor = UIColor.blackColor()
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        setup()
    }
    
    private func bindViewModel() {

    }
    
    //MARK: - ACTIONS

    @IBAction func onSaveButton() {
        if currentEditingState == .Default {
            if savingIsPossible().0 {
                saveProfile()
                let segueID = presentingViewController!.isKindOfClass(ProfileStatsVC) ? Constants.changesSaved : Constants.returnToMainVCSegue
                performSegueWithIdentifier(segueID, sender: self)
            } else {
                postAlertOnLackOfInfo(message: savingIsPossible().1)
            }
        } else {
            currentEditingState = .Default
        }
    }
    
    @IBAction func datePickerChangedValue(sender: UIDatePicker) {
        birthdayLabel.text = dateFormatter.stringFromDate(datePicker.date)
        selectedBirthday = sender.date
    }
    
    
    @IBAction func maleSelected(sender: UIButton) {
        selectedGender = .Male
        maleButton.selected = true
        femaleButton.selected = false
        nameTextField.resignFirstResponder()

    }
    
    @IBAction func femaleSelected(sender: UIButton) {
        selectedGender = .Female
        maleButton.selected = false
        femaleButton.selected = true
        nameTextField.resignFirstResponder()

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
    
    override func propertisViewTapped(sender: UITapGestureRecognizer) {
        super.propertisViewTapped(sender)
        let tapPoint = sender.locationInView(propertiesView)
        let tapedView = propertiesView.hitTest(tapPoint, withEvent: nil)
        
        if let view = tapedView {
            if view.tag == 2 {
                birthdayLabel.text = dateFormatter.stringFromDate(datePicker.date)
                selectedBirthday = datePicker.date
            } else if view.tag == 3 {
                countryLabel.text = countryPicker.selectedCountryName
                selectedCountry = countryPicker.selectedCountryName
            }
        }
    }
    
    //MARK: - SETUP / SAVE

    func setup() {
        if userProfile != nil {
            selectedGender = userProfile.userGender()
            tuneGenderButtons()
            setupImageViewForAvatar()

            nameTextField.text = userProfile.name
            birthdayLabel.text = dateFormatter.stringFromDate(userProfile.birthday)
            datePicker.date = userProfile.birthday
            countryLabel.text = userProfile.country
            countryPicker.selectedCountryName = userProfile.country
            
            if let avatar = UIImage(data: userProfile.photo) {
                avatarImage.image = avatar
            }
            
        } else {
            
            datePicker.date = Profile.defaultBirthday()
            countryPicker.selectedCountryName = Profile.defaultCountry()
        }
    }
    

    
    func tuneGenderButtons() {
        if userProfile == nil {
            deselectGenderButtons()
        } else {
            if let gender = selectedGender {
                if gender == .Male {
                    maleButton.selected = true
                } else {
                    femaleButton.selected = true
                }
            } else {
                deselectGenderButtons()
            }
        }
    }
    
    func deselectGenderButtons() {
        maleButton.selected = false
        femaleButton.selected = false
    }
    
    
    
    func postAlertOnLackOfInfo(message message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func savingIsPossible() -> (Bool, String) {
        if nameTextField.text == "" {
            return (false, "Please, enter your name")
        }
        if selectedGender == nil {
            return (false, "Please, select your gender")
        }
        if birthdayLabel.text == Constants.defaultDateLabelText {
            return (false, "Please, select your birthday date")
        }
        if countryLabel.text == Constants.defaultCountryLabelText {
            return (false, "Please, select your country")
        }
        return (true, "")
    }
    
    func saveProfile() {
        if userProfile == nil {
            let context = CoreDataStack.sharedInstance.managedObjectContext
            userProfile = Profile.userProfileInManagedContext(context!)
        }
        userProfile.name = nameTextField.text!
        userProfile.birthday = dateFormatter.dateFromString(birthdayLabel.text!)!
        userProfile.country = countryLabel.text!
        userProfile.gender = Profile.genderWithEnum(selectedGender!)
        if avatarImage.image != UIImage(named: "avatarPickerImage") {
            userProfile.photo = UIImagePNGRepresentation(avatarImage.image!)!
        } else {
            userProfile.photo = UIImagePNGRepresentation(UIImage(named: "defaultUserImage")!)!
        }
        userProfile.saveChangesToCoreData()
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SaveChangesToProfile" {
            
        }
        
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

extension ProfileEditingVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentEditingState = .Default
        selectedName = textField.text
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        currentEditingState = (currentEditingState != .Name) ? .Name : .Default
    }
}

extension ProfileEditingVC: CountryPickerDelegate {
    func countryPicker(picker: CountryPicker!, didSelectCountryWithName name: String!, code: String!) {
        countryLabel.text = name
        selectedCountry = name
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
