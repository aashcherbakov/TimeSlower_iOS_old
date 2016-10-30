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
    @IBOutlet weak var savedTimeLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var savedTimeCircle: CircleProgress!
    @IBOutlet weak var successCircle: CircleProgress!
    @IBOutlet weak var newActivityButton: UIButton!
    
    private let dataStore = DataStore()
    
    var countdownTimer: MZTimerLabel!
    var profile: Profile?

    private var savedTime: Double = 0
    private var success: Double = 0
    private var expirationDate = Date()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true

        setupData()
        setupDesign()
        launchTimer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAvatarForm()
    }
    fileprivate func setupData() {
        guard let profile = profile else {
            return
        }
        
        let allActivities = dataStore.activities(forDate: nil, type: .routine)
        
        savedTime = totalSaved(fromActivities: allActivities)
        success = averageSuccess(fromActivities: allActivities)
        expirationDate = profile.dateOfApproximateLifeEnd()
    }
    
    private func totalSaved(fromActivities activities: [Activity]) -> Double {
        guard activities.count > 0 else { return 0 }
        return activities.map { (activity) -> Double in
            return activity.totalTimeSaved
        }.reduce(0, +)
    }
    
    private func averageSuccess(fromActivities activities: [Activity]) -> Double {
        guard activities.count > 0 else { return 0 }
        let totalSuccess = activities.map { (activity) -> Double in
            return activity.averageSuccess
            }.reduce(0, +)
        
        return totalSuccess / Double(activities.count)
    }
    
    fileprivate func setupDesign() {
        displaySavedTime()
        displayAverageSuccess()
        displayGreeting()
        displayAvatar()
    }
    
    private func displaySavedTime() {
        savedTimeLabel.text = String(format: "%.1f", savedTime)
        savedTimeCircle.thicknessRatio = 0.05
        savedTimeCircle.updateProgress(CGFloat(success))
    }
    
    private func displayAverageSuccess() {
        successLabel.text = String(format: "%.1f", success) + "%"
        successCircle.thicknessRatio = 0.05
        successCircle.updateProgress(CGFloat(success))
    }
    
    private func displayGreeting() {
        guard let profile = profile else { return }
        userGreatingLabel.text = "Hello \(profile.name)"
    }
    
    private func displayAvatar() {
        avatarImageView.image = profile?.photo
    }
    
    private func setupAvatarForm() {
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
        let editProfileVC: ProfileEditingVC = ControllerFactory.createController()
        editProfileVC.profile = profile
        editProfileVC.delegate = self
        present(editProfileVC, animated: true, completion: nil)
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
        countdownTimer = MZTimerLabel(label: timerLabel, andTimerType: MZTimerLabelTypeTimer)
        countdownTimer.setCountDownTo(expirationDate)
        countdownTimer.resetTimerAfterFinish = false
        
        let timerSecondsToSet = expirationDate.timeIntervalSinceNow
        countdownTimer.timeFormat = NSString(format: "%.0f:mm:ss", round((timerSecondsToSet - 60*60) / 60 / 60)) as String
        countdownTimer.start()
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

extension ProfileStatsVC: ProfileEditingDelegate {
    func didUpdate(profile: Profile) {
        self.profile = profile
        setupData()
        setupDesign()
        launchTimer()        
    }
}
