//
//  MotivationControl.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/16/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import UIKit
import TimeSlowerKit

protocol ActivityShareDelegate {
    func shareMotivationImage()
}

/**
 *  Protocol that combines Share and Dots cell setup interface
 */
protocol MotivationControlCell {
    /**
     Setup method for motivation control cells
     
     - parameter stats:    LifetimeStats objects with activity stats
     - parameter image:    image with dots corresponding to stats
     - parameter period:   Period of time that represents amount of dots
     - parameter delegate: delegate for social sharing
     */
    func setupWithStats(_ stats: LifetimeStats, image: UIImage?, period: Period?, delegate: MotivationShareDelegate)
}

/// UIControl subclass that displays user lifetime stats with circle images. Reusable.
internal class MotivationControl: UIControl {
    
    enum MotivationCellType: Int {
        case years
        case months
        case days
        case hours
        case share
    }
    
    fileprivate struct Constants {
        static let numberOfCells = 4
        static let dotsImageWidthMultiplier: CGFloat = 0.8
        static let dotsImageHeightMultiplier: CGFloat = 0.2
    }
    
    @IBOutlet fileprivate(set) weak var pageControl: UIPageControl!
    @IBOutlet fileprivate(set) weak var view: UIView!
    @IBOutlet fileprivate(set) weak var collectionView: UICollectionView!
    fileprivate(set) var stats: LifetimeStats?
    fileprivate(set) var cellTypes: [MotivationCellType]?
    fileprivate(set) var dotsImages = [UIImage]()
    fileprivate(set) var delegate: ActivityShareDelegate?
    
    fileprivate var currentPage: Int {
        get {
            return Int(collectionView.contentOffset.x / view.bounds.size.width)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupXib()
    }
    
    // MARK: - Internal Functions
    
    func setupWithLifetimeStats(_ stats: LifetimeStats, shareDelegate: ActivityShareDelegate) {
        self.delegate = shareDelegate
        self.stats = stats
        let types = cellTypesForStats(stats)
        cellTypes = types
        dotsImages = createImages(forStats: stats, inCellTypes: types)
        
        pageControl.numberOfPages = dotsImages.count + 1
        setupPageDotsColors()
    }
    
    // MARK: - Private Functions
    
    fileprivate func setupPageDotsColors() {
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor.darkRed()
        pageController.currentPageIndicatorTintColor = UIColor.white
        pageController.backgroundColor = UIColor.clear
    }
    
    fileprivate func createImages(forStats stats: LifetimeStats, inCellTypes cellTypes: [MotivationCellType]) -> [UIImage] {
        guard dotsImages.count == 0 else { return dotsImages }
        
        var images = [UIImage]()
        for type in cellTypes {
            if let numberOfDots = numberOfDotsForCellType(type, stats: stats) {
                let image = Motivator.imageWithDotsAmount(numberOfDots, inFrame: frameForDotsImage())
                images.append(image)
            }
        }
        
        return images
    }
    
    fileprivate func frameForDotsImage() -> CGRect {
        let screenSize = UIScreen.main.bounds.size
        return CGRect(x: 0, y: 0, width: round(screenSize.width * Constants.dotsImageWidthMultiplier),
                          height: round(screenSize.height * Constants.dotsImageHeightMultiplier))
    }
    
    fileprivate func numberOfDotsForCellType(_ cellType: MotivationCellType, stats: LifetimeStats) -> Int? {
        switch cellType {
        case .years: return stats.summYears.intValue
        case .months: return stats.summMonth.intValue
        case .days: return stats.summDays.intValue
        case .hours: return stats.summHours.intValue
        default: return nil
        }
    }
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(MotivationControl.className, owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: MotivationDotsCollectionViewCell.className, bundle: nil),
                                   forCellWithReuseIdentifier: MotivationDotsCollectionViewCell.className)
        collectionView.register(UINib(nibName: MotivationShareCollectionViewCell.className, bundle: nil),
                                   forCellWithReuseIdentifier: MotivationShareCollectionViewCell.className)
    }
    
    fileprivate func cellTypesForStats(_ stats: LifetimeStats) -> [MotivationCellType] {
        var cellTypes: [MotivationCellType] = [.months, .days]
        if stats.summYears.doubleValue > 1 {
            cellTypes.insert(.years, at: 0)
        } else {
            cellTypes.append(.hours)
        }
        
        cellTypes.append(.share)
        return cellTypes
    }
    
    fileprivate func cellTypeForIndexPath(_ indexPath: IndexPath) -> MotivationControlCell.Type? {
        guard let cellTypes = cellTypes , (indexPath as NSIndexPath).item < cellTypes.count else {
            return nil
        }
        
        let cellType = cellTypes[(indexPath as NSIndexPath).item]
        
        switch cellType {
        case .share: return MotivationShareCollectionViewCell.self
        default: return MotivationDotsCollectionViewCell.self
        }
    }
    
    fileprivate func periodForCellType(_ cellType: MotivationCellType) -> Period? {
        switch cellType {
        case .days: return Period.days
        case .hours: return Period.hours
        case .months: return Period.months
        case .years: return Period.years
        default: return nil
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MotivationControl: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UIScrollViewDelegate

extension MotivationControl: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
    }

}

// MARK: - UICollectionViewDataSource

extension MotivationControl: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let
            cellType = cellTypeForIndexPath(indexPath),
            let cellTypes = cellTypes,
            let stats = stats , (indexPath as NSIndexPath).item < cellTypes.count
        else {
            return UICollectionViewCell()
        }
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellType), for: indexPath) as? MotivationControlCell {
            let period = periodForCellType(cellTypes[(indexPath as NSIndexPath).item])
            let image = imageForIndexPath(indexPath, fromArray: dotsImages)
            cell.setupWithStats(stats, image: image, period: period, delegate: self)
            return cell as! UICollectionViewCell
        }
        
        return UICollectionViewCell()
    }
    
    fileprivate func imageForIndexPath(_ indexPath: IndexPath, fromArray array: [UIImage]) -> UIImage? {
        guard (indexPath as NSIndexPath).item < array.count else { return nil }
        return array[(indexPath as NSIndexPath).item]
    }
}

// MARK: - MotivationShareDelegate

extension MotivationControl: MotivationShareDelegate {
    func motivationShareDelegateDidTapShareButton() {
        delegate?.shareMotivationImage()
    }
}
