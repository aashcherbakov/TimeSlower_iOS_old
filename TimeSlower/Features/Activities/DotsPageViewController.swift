//
//  DotsPageViewController.swift
//  TimeSlower2
//
//  Created by Aleksander Shcherbakov on 5/8/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class DotsPageViewController: UIViewController {

    struct Constants {
        static let titleViewHeightScale: CGFloat = 0.15
        static let dotsImageHeightScale: CGFloat = 0.30
        static let dotsImageWidthScale: CGFloat = 0.63
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    
    var pageIndex: Int?
    var titleText: String!
    var periodText: String!
    var dots: Int!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        titleViewHeight.constant = kUsableViewHeight * Constants.titleViewHeightScale
        imageViewHeight.constant = kUsableViewHeight * Constants.dotsImageHeightScale
        imageViewWidth.constant = kUsableViewWidth * Constants.dotsImageWidthScale
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = titleText
        periodLabel.text = periodText
        
        let rectToPass = imageView.bounds
        imageView.image = Motivator.imageWithDotsAmount(dots: dots, inFrame: rectToPass)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
