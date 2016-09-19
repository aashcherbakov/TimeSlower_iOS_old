//
//  NSString+Extension.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/4/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

public extension NSString {
    @objc public func compareDateRepresentationOfString(_ otherString: String) -> ComparisonResult {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        
        let firstDate = dateFormatter.date(from: self as String)
        let secondDate = dateFormatter.date(from: otherString)
        return firstDate!.compare(secondDate!)
    }
}
