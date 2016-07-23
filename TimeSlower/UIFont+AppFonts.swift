//
//  UIColor+AppColors.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/1/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

extension UIFont {
    class func sourceSansRegular() -> UIFont {
        return UIFont(name: "SourceSansPro-Regular", size: 16.0)!
    }
    
    class func mainBold(size: CGFloat) -> UIFont {
        return UIFont(name: "SourceSansPro-Bold", size: size)!
    }
    
    class func mainRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "SourceSansPro-Regular", size: size)!
    }
    
}