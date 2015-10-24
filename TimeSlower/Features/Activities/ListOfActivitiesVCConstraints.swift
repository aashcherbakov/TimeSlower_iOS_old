//
//  ListOfActivitiesVCConstraints.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 7/16/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class ListOfActivitiesVCConstraints: UIViewController {
    
    struct Constants {
        static let tableViewHeightScale: CGFloat = 0.59
        static let typeSelectorHeightScale: CGFloat = 0.11
        static let basisSelectorHeightScale: CGFloat = 0.08
        static let typeAllignmentFromSenterScale: CGFloat = 0.2
        static let buttonTopOffset: CGFloat = 0.03
        static let buttonDownOffset: CGFloat = 0.05
        static let buttonHeightScale: CGFloat = 0.09
        static let buttonWidthScale: CGFloat = 0.85
    }

    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var typeSelectorHeight: NSLayoutConstraint!
    @IBOutlet weak var basisSelectorHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonTopOffset: NSLayoutConstraint!
    @IBOutlet weak var buttonDownOffset: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setupDefaultConstraints()
    }

    func setupDefaultConstraints() {
        tableViewHeight.constant = kUsableViewHeight * Constants.tableViewHeightScale
        typeSelectorHeight.constant = kUsableViewHeight * Constants.typeSelectorHeightScale
        basisSelectorHeight.constant = kUsableViewHeight * Constants.basisSelectorHeightScale
        buttonTopOffset.constant = kUsableViewWidth * Constants.buttonTopOffset
        buttonDownOffset.constant = kUsableViewWidth * Constants.buttonDownOffset
        buttonHeight.constant = kUsableViewHeight * LayoutConstants.buttonHeightScale
        buttonWidth.constant = kUsableViewWidth * LayoutConstants.buttonWidthScale
    }


}
