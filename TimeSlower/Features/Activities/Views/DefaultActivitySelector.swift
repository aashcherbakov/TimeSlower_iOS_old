//
//  DefaultActivitySelector.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 8/3/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class DefaultActivitySelector: UIControl {

    enum TypeToDisplay {
        case Routines
        case Goals
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var view: UIView!
    
    var selectedSegmentIndex: Int? {
        didSet {
            sendActionsForControlEvents(.ValueChanged)
        }
    }
    var selectedActivityName: String?
    var activityLabels: [String]!
    var activityImages: [String]!
    var nibLoaded = false

    
    var typeToDisplay: TypeToDisplay! {
        didSet {
            activityLabels = (typeToDisplay == .Routines) ? defaultRoutines : defaultGoals
            activityImages = (typeToDisplay == .Routines) ? routinesImageNames : goalsImageNames
        }
    }
    
    let kDefaultActivityCellID = "DefaultActivitySelectorCell"
    
    let defaultGoals = [ "Learn Chinese", "Write a novel", "Meditate", "Family time", "Sport up", "Learn to play piano" ]
    let goalsImageNames = [ "chineseIcon", "booksIcon", "meditationIcon", "familyIcon", "sportIcon", "pianoIcon" ]
    let defaultRoutines = [ "Morning shower", "Lunch break", "Sleep", "Social media", "Coffee breaks", "Cooking" ]
    let routinesImageNames = [ "showerIcon", "mealIcon", "sleepIcon", "socialIcon", "coffeeIcon", "cookingIcon" ]
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCollectionViewItemSize()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("DefaultActivitySelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    func setupCollectionViewItemSize() {
        let width = CGRectGetWidth(collectionView!.frame) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
}

extension DefaultActivitySelector: UICollectionViewDataSource {
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if !nibLoaded {
            let nib = UINib(nibName: kDefaultActivityCellID, bundle: nil)
            collectionView.registerNib(nib, forCellWithReuseIdentifier: kDefaultActivityCellID)
            nibLoaded = true
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kDefaultActivityCellID, forIndexPath: indexPath) as! DefaultActivitySelectorCell

        cell.imageView.image = UIImage(named: routinesImageNames[indexPath.item])
        cell.nameLabel.text = defaultRoutines[indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
}

extension DefaultActivitySelector: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! DefaultActivitySelectorCell
        selectedActivityName = selectedCell.nameLabel.text
        selectedSegmentIndex = indexPath.item
        animateSelection(selectedCell)
    }
    
    func animateSelection(selectedCell: DefaultActivitySelectorCell) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            selectedCell.backgroundCircle.backgroundColor = UIColor.purpleRed()
            }) { (finished) -> Void in
                selectedCell.backgroundCircle.backgroundColor = UIColor.extraLightGray()
        }
    }
}




















