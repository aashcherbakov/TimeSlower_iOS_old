//
//  MotivationViewController.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/11/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

class MotivationViewController: UIViewController {

    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var activityBasisLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var motivationControl: MotivationControl!
    @IBOutlet weak var activityStatsView: MotivationStatsView!
    fileprivate(set) var activity: Activity?
    fileprivate let dateFormatter = StaticDateFormatter.shortDateNoTimeFromatter
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func okButtonTapped(_ sender: AnyObject) {
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func setupWithActivity(_ activity: Activity) {
        self.activity = activity
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let activity = activity else { return }
        
        activityNameLabel.text = activity.name
        activityBasisLabel.text = activity.basis().description()
        
        summaryLabel.attributedText = motivationDescriptionForActivity(activity)
        
        setupMotivationControlWithActivity(activity)
        setupStatsViewWithActivity(activity)
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        motivationControl.setNeedsLayout()
        motivationControl.layoutIfNeeded()
    }
    
    // MARK: - Private Functions
    
    fileprivate func descriptionForActivityBasis(_ activity: Activity) -> String {
        let basis = activity.basis()
        
        switch basis {
        case .random: return "\(activity.days.count) days a week"
        case .daily: return "daily"
        case .weekends: return "on weekends"
        case .workdays: return "during workdays"
        }
    }
    
    fileprivate func setupMotivationControlWithActivity(_ activity: Activity) {
        let lifeStats = lifeStatsForActivity(activity)
        motivationControl.setupWithLifetimeStats(lifeStats, shareDelegate: self)
    }
    
    fileprivate func setupStatsViewWithActivity(_ activity: Activity) {
        let startTime = dateFormatter.string(from: activity.startTime())
        activityStatsView.setupWithStartTime(startTime, duration: activity.duration().shortDescription())
    }
    
    // TODO: move to activity?
    fileprivate func motivationDescriptionForActivity(_ activity: Activity) -> NSAttributedString {
        // TODO: here will be a bug if we save hours
        let duration = String(Int(activity.timeToSave()))
        let basis = descriptionForActivityBasis(activity)
        let description = "cutting \(duration) minutes of \(activity.name) \(basis) will save in your lifetime:".uppercased()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let descriptionText = NSMutableAttributedString(string: description)
        
        
        descriptionText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, descriptionText.length))
        let attributes = [NSParagraphStyleAttributeName  : paragraphStyle,
                          NSFontAttributeName            : UIFont.mainRegular(15),
                          NSForegroundColorAttributeName : UIColor.white]
        descriptionText.addAttributes(attributes, range: NSMakeRange(0, descriptionText.length))

        let text = descriptionText.string as NSString
        let durationRange = text.range(of: duration)
        let nameRange = text.range(of: activity.name.uppercased())
        let basisRange = text.range(of: basis.uppercased())
        
        descriptionText.addAttribute(NSFontAttributeName, value: UIFont.mainBold(15), range: durationRange)
        descriptionText.addAttribute(NSFontAttributeName, value: UIFont.mainBold(15), range: nameRange)
        descriptionText.addAttribute(NSFontAttributeName, value: UIFont.mainBold(15), range: basisRange)

        
        return descriptionText
    }
    
    // TODO: move to activity?
    fileprivate func lifeStatsForActivity(_ activity: Activity) -> LifetimeStats {
        let hours = activity.stats.summHours
        return LifetimeStats(withHours: NSNumber(value: hours))
    }
    
    fileprivate func sharingImageForActivity(_ activity: Activity) -> UIImage {
        let lifestats = lifeStatsForActivity(activity)
        let description = motivationDescriptionForActivity(activity)
        let illustrator = MotivationIllustrator(withStats: lifestats, descriptionString: description)
        return illustrator.createImageToShare()
    }

}

extension MotivationViewController: ActivityShareDelegate {
    func shareMotivationImage() {
        guard let activity = activity else { return }
        
        let image = sharingImageForActivity(activity)
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.excludedActivityTypes = [UIActivityType.print, UIActivityType.copyToPasteboard,
                                                    UIActivityType.assignToContact, UIActivityType.addToReadingList]
        
        present(activityController, animated: true, completion: nil)
    }
}
