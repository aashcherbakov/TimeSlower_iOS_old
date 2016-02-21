//
//  EditActivityDataView.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/20/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import RxSwift
import TimeSlowerKit

class EditActivityDataView: UIView {
    
    private struct Constants {
        static let defaultCellHeight: CGFloat = 56
        static let nameExpandedHeight: CGFloat = 286
        static let basisExpandedHeight: CGFloat = 128
        static let startTimeExpandedHeight: CGFloat = 218
    }
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var editNameView: EditActivityNameView!
    @IBOutlet weak var nameViewHeightConstraint: NSLayoutConstraint!
    
    var selectedName = Variable<String>("")
    var selectedBasis = Variable<ActivityBasis?>(nil)
    private var disposableBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
        
        setupEvents()
    }

    func setupEvents() {
        editNameView.selectedName
            .subscribeNext {
                [weak self] (name) -> Void in
                self?.selectedName.value = name
            }
            .addDisposableTo(disposableBag)
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("EditActivityDataView", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
        
        updateDesignForState(.AddName)
    }
    
    func updateDesignForState(state: EditActivityState) {
        switch state {
        case .NoData: break
        case .AddName: nameViewHeightConstraint.constant = Constants.nameExpandedHeight
        case .AddBasis: nameViewHeightConstraint.constant = Constants.defaultCellHeight
        default: return
        }
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
            self.editNameView.layoutSubviews()
        }
    }
}