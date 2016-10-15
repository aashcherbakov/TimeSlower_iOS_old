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
        case routines
        case goals
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var view: UIView!
    
    var selectedSegmentIndex: Int? {
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    var selectedActivityName: String?
    var activityLabels: [String]!
    var activityImages: [String]!
    var nibLoaded = false

    
    var typeToDisplay: TypeToDisplay! {
        didSet {
            activityLabels = (typeToDisplay == .routines) ? defaultRoutines : defaultGoals
            activityImages = (typeToDisplay == .routines) ? routinesImageNames : goalsImageNames
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
        Bundle.main.loadNibNamed("DefaultActivitySelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    /**
     Method recalculates width after views are layed out. Needs to be called in layoutSubviews method of superview
     */
    func setupCollectionViewItemSize() {
        let width = collectionView!.frame.width / 3
        let height = collectionView!.frame.height / 2
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: height)
    }
}

extension DefaultActivitySelector: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !nibLoaded {
            let nib = UINib(nibName: kDefaultActivityCellID, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: kDefaultActivityCellID)
            nibLoaded = true
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kDefaultActivityCellID, for: indexPath) as! DefaultActivitySelectorCell

        cell.imageView.image = UIImage(named: routinesImageNames[(indexPath as NSIndexPath).item])
        cell.nameLabel.text = defaultRoutines[(indexPath as NSIndexPath).item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
}

extension DefaultActivitySelector: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! DefaultActivitySelectorCell
        selectedActivityName = selectedCell.nameLabel.text
        selectedSegmentIndex = (indexPath as NSIndexPath).item
        animateSelection(selectedCell)
    }
    
    func animateSelection(_ selectedCell: DefaultActivitySelectorCell) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            selectedCell.backgroundCircle.backgroundColor = UIColor.purpleRed()
            }, completion: { (finished) -> Void in
                selectedCell.backgroundCircle.backgroundColor = UIColor.extraLightGray()
        }) 
    }
}
