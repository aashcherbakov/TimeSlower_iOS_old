//
//  MotivationControl.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/16/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

protocol MotivationControlCell {
    func setupWithStats(stats: LifetimeStats, image: UIImage?, period: Period?, delegate: MotivationShareDelegate)
}

internal class MotivationControl: UIControl {
    
    enum MotivationCellType: Int {
        case Years
        case Months
        case Days
        case Hours
        case Share
    }
    
    private struct Constants {
        static let numberOfCells = 4
        static let defaultDotsFrame = CGRectMake(0, 0, 220, 110)
    }
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    private(set) var stats: LifetimeStats?
    private(set) var cellTypes: [MotivationCellType]?
    private(set) var dotsImages = [UIImage]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupXib()
    }
    
    // MARK: - Internal Functions
    
    func setupWithLifetimeStats(stats: LifetimeStats) {
        self.stats = stats
        let types = cellTypesForStats(stats)
        cellTypes = types
        dotsImages = createImages(forStats: stats, inCellTypes: types)
    }
    
    // MARK: - Private Functions
    
    private func createImages(forStats stats: LifetimeStats, inCellTypes cellTypes: [MotivationCellType]) -> [UIImage] {
        guard dotsImages.count == 0 else { return dotsImages }
        
        var images = [UIImage]()
        for type in cellTypes {
            if let numberOfDots = numberOfDotsForCellType(type, stats: stats) {
                let image = Motivator.imageWithDotsAmount(dots: numberOfDots, inFrame: Constants.defaultDotsFrame)
                images.append(image)
            }
        }
        
        return images
    }
    
    private func numberOfDotsForCellType(cellType: MotivationCellType, stats: LifetimeStats) -> Int? {
        switch cellType {
        case .Years: return stats.summYears.integerValue
        case .Months: return stats.summMonth.integerValue
        case .Days: return stats.summDays.integerValue
        case .Hours: return stats.summHours.integerValue
        default: return nil
        }
    }
    
    private func setupXib() {
        NSBundle.mainBundle().loadNibNamed(MotivationControl.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.registerNib(UINib(nibName: MotivationDotsCollectionViewCell.className, bundle: nil),
                                   forCellWithReuseIdentifier: MotivationDotsCollectionViewCell.className)
        collectionView.registerNib(UINib(nibName: MotivationShareCollectionViewCell.className, bundle: nil),
                                   forCellWithReuseIdentifier: MotivationShareCollectionViewCell.className)
    }
    
    private func cellTypesForStats(stats: LifetimeStats) -> [MotivationCellType] {
        var cellTypes: [MotivationCellType] = [.Months, .Days]
        if stats.summYears.doubleValue > 1 {
            cellTypes.insert(.Years, atIndex: 0)
        } else {
            cellTypes.append(.Hours)
        }
        
        cellTypes.append(.Share)
        return cellTypes
    }
    
    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> MotivationControlCell.Type? {
        guard let cellTypes = cellTypes where indexPath.item < cellTypes.count else {
            return nil
        }
        
        let cellType = cellTypes[indexPath.item]
        
        switch cellType {
        case .Share: return MotivationShareCollectionViewCell.self
        default: return MotivationDotsCollectionViewCell.self
        }
    }
    
    private func periodForCellType(cellType: MotivationCellType) -> Period? {
        switch cellType {
        case .Days: return Period.Days
        case .Hours: return Period.Hours
        case .Months: return Period.Months
        case .Years: return Period.Years
        default: return nil
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension MotivationControl: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return view.frame.size
    }
}

// MARK: - UICollectionViewDataSource

extension MotivationControl: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.numberOfCells
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let
            cellType = cellTypeForIndexPath(indexPath),
            cellTypes = cellTypes,
            stats = stats where indexPath.item < cellTypes.count
        else {
            return UICollectionViewCell()
        }
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(cellType), forIndexPath: indexPath) as? MotivationControlCell {
            let period = periodForCellType(cellTypes[indexPath.item])
            let image = imageForIndexPath(indexPath, fromArray: dotsImages)
            cell.setupWithStats(stats, image: image, period: period, delegate: self)
            return cell as! UICollectionViewCell
        }
        
        return UICollectionViewCell()
    }
    
    private func imageForIndexPath(indexPath: NSIndexPath, fromArray array: [UIImage]) -> UIImage? {
        guard indexPath.item < array.count else { return nil }
        return array[indexPath.item]
    }
}

// MARK: - UICollectionViewDelegate

extension MotivationControl: UICollectionViewDelegate {
    
}

// MARK: - MotivationShareDelegate

extension MotivationControl: MotivationShareDelegate {
    func motivationShareDelegateDidTapShareButton() {
        // TODO: implement sharing
    }
}



