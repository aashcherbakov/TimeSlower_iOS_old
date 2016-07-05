//
//  NSString+Extension.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

extension NSString {
        func compareDateRepresentationOfString(otherString: String) -> NSComparisonResult {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.dateStyle = .ShortStyle
        
        let firstDate = dateFormatter.dateFromString(self as String)
        let secondDate = dateFormatter.dateFromString(otherString)
        return firstDate!.compare(secondDate!)
    }
}