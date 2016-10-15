//
//  ProfileStatsVC.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/11/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit
import CoreData

class ProfileStatsVC: ProfileStatsVCConstraints {

    struct Constants {
        static let createActivitySegue = "CreateNewActivity"
    }
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var userGreatingLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarFrameView: UIView!
    
    @IBOutlet weak var totalHoursSavedLabel: UILabel!
    @IBOutlet weak var totalHoursSpentLabel: UILabel!
    
    @IBOutlet weak var routinesCircle: CircleProgress!
    @IBOutlet weak var goalsCircle: CircleProgress!
    
    
    var countdownTimer: MZTimerLabel!
    var profile: Profile! {
        didSet {
            // TODO: overall stats
//            profileStats = profile.timeStatsForPeriod(.Lifetime)
        }
    }
    
//    var profileStats: Profile.DailyStats!

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        if profile != nil {
            setup()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    func setup() {
        setupLabels()
        setupAvatarForm()
        setupCircles()
        launchTimer()
    }
    
    func setupCircles() {
        for circle in [routinesCircle, goalsCircle] {
//            circle?.progressBarWidth = 2
            circle?.trackTintColor = UIColor.white
            circle?.progressTintColor = UIColor.darkRed()
        }
        
        // TODO: here we should come from date of first use
//        let routineProgress = profileStats.factSaved / (profileStats.plannedToSave / 60)
//        routinesCircle.progress = routineProgress > 0 ? routineProgress : 0
//        
//        let goalProgress = profileStats.factSpent / (profileStats.plannedToSpend / 60)
//        goalsCircle.progress = goalProgress > 0 ? goalProgress : 0
    }
    

    func setupLabels() {
        let format = ".0"
//        totalHoursSavedLabel.text = "\(profileStats.factSaved.format(format))"
//        totalHoursSpentLabel.text = "\(profileStats.factSpent.format(format))"
//        userGreatingLabel.text = "Hello " + profile.name
//        
//        if let photoData = profile.photo {
//            avatarImageView.image = UIImage(data: photoData)
//        }
    }
    
    func setupAvatarForm() {
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
        avatarImageView.clipsToBounds = true
        avatarFrameView.layer.cornerRadius = avatarFrameView.bounds.height / 2
        avatarFrameView.layer.borderWidth = 1
        avatarFrameView.layer.borderColor = UIColor.darkRed().cgColor
    }
    
    //MARK: Action
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onNewActivityButton(_ sender: UIButton) {
        let createActivityVC: EditActivityVC = ControllerFactory.createController()
        createActivityVC.userProfile = profile
        navigationController?.pushViewController(createActivityVC, animated: true)
    }

    @IBAction func onEditButton(_ sender: UIButton) {
        if let editProfileVC = storyboard?.instantiateViewController(withIdentifier: ProfileEditingVC.className) as? ProfileEditingVC {
            navigationController?.pushViewController(editProfileVC, animated: true)
        }
    }
    
    //MARK: - Timer setup
    
    func launchTimer() {
        if countdownTimer != nil {
            if !countdownTimer.counting {
                setupTimerCountdown()
            } else {
                restartTimerIfProfileHasChanged()
            }
        } else {
            setupTimerCountdown()
        }
    }
    
    func restartTimerIfProfileHasChanged() {
        let timeTillFinalDate = profile?.dateOfApproximateLifeEnd().timeIntervalSinceNow
        let timeTillEndOfCountdown = countdownTimer.getTimeRemaining()
        
        if timeTillFinalDate != timeTillEndOfCountdown {
            reloadTimer()
        }
    }
    
    func setupTimerCountdown() {
//        countdownTimer = MZTimerLabel(label: timerLabel, andTimerType: MZTimerLabelTypeTimer)
//        countdownTimer.setCountDownTo(profile?.dateOfDeath)
//        countdownTimer.resetTimerAfterFinish = false
//        
//        let timerSecondsToSet = profile?.dateOfDeath.timeIntervalSinceNow
//        countdownTimer.timeFormat = NSString(format: "%.0f:mm:ss", round((timerSecondsToSet! - 60*60) / 60 / 60)) as String
//        countdownTimer.start()
    }
    
    func reloadTimer() {
        if countdownTimer != nil {
            countdownTimer.removeFromSuperview()
            countdownTimer = nil
            setupTimerCountdown()
        }
    }
    

    
    // MARK: - Navigation
    @IBAction func dismissProfileEditingController(_ segue: UIStoryboardSegue) { }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.createActivitySegue {
            if let vc = segue.destination as? EditActivityVC {
                vc.userProfile = profile
            }
        }
    }
    

}
