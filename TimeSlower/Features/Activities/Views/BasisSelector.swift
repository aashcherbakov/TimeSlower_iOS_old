//
//  BasisSelector.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/17/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit
import TimeSlowerKit
import RxSwift

/// UIControl subclass used to select activity basis on high level: Daily, Workdays or Weekends
class BasisSelector: UIControl {

    // MARK: - Properties
    
    /// Observable selected index
    var selectedSegmentIndex = Variable<Int?>(nil)
    
    @IBOutlet private weak var weekendsLabel: UILabel!
    @IBOutlet private weak var workdaysLabel: UILabel!
    @IBOutlet private weak var dailyLabel: UILabel!
    @IBOutlet private var view: UIView!
    @IBOutlet private weak var dailySelectedIndicator: UIImageView!
    @IBOutlet private weak var workdaysSelectedIndicator: UIImageView!
    @IBOutlet private weak var weekendsSelectedIndicator: UIImageView!
    
    private var selectedIconImage = UIImage(named: "selectedIcon")
    private var deselectedIconImage = UIImage(named: "deselectedIcon")
    
    private let disposableBag = DisposeBag()
    
    // MARK: - Overridden Methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDesign()
        setupEvents()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touchLocation = touches.first?.locationInView(self) {
            selectedSegmentIndex.value = selectedIndexFromLocation(touchLocation)
        }
    }
    
    // MARK: - Internal Methods
    
    func updateSegmentedIndexForBasis(basis: ActivityBasis) {
        configureButtonsForIndex(basis.rawValue)
    }
    
    // MARK: - Setup Methods
    
    private func setupDesign() {
        NSBundle.mainBundle().loadNibNamed("BasisSelector", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    private func setupEvents() {
        selectedSegmentIndex
            .subscribeNext { [weak self] (value) -> Void in
                self?.configureButtonsForIndex(value)
            }
            .addDisposableTo(disposableBag)
    }
    
    // MARK: - Private Methods
    
    private func selectedIndexFromLocation(touchLocation: CGPoint) -> Int {
        let sectionWidth = view.frame.width / 3
        if touchLocation.x < sectionWidth {
            return 0
        } else if touchLocation.x > (sectionWidth * 2) {
            return 2
        } else {
            return 1
        }
    }
    
    private func configureButtonsForIndex(index: Int?) {
        if let index = index where index < 4 && index >= 0 {
            configureButtons(index)
        }
    }
    
    private func configureButtons(type: Int) {
        for i in 0 ..< iconsArray.count {
            if i == type {
                iconsArray[i].image = selectedIconImage
                labelsArray[i].textColor = UIColor.purpleRed()
            } else {
                iconsArray[i].image = deselectedIconImage
                labelsArray[i].textColor = UIColor.lightGray()
            }
        }
    }
    
    // MARK: - Lazy Variables
    
    private lazy var labelsArray: [UILabel] = {
        return [self.dailyLabel, self.workdaysLabel, self.weekendsLabel]
    }()
    
    private lazy var iconsArray: [UIImageView] = {
        return [
            self.dailySelectedIndicator,
            self.workdaysSelectedIndicator,
            self.weekendsSelectedIndicator
        ]
    }()
}
