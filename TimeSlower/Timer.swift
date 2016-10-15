//
//  Timer.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/24/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

internal class Timer: NSObject {
    fileprivate let block: () -> Void
    fileprivate var timer: Foundation.Timer?
    fileprivate let interval: Double
    
    init(_ interval: Double, block: @escaping () -> ()) {
        self.block = block
        self.interval = interval
    }
    
    func start() {
        timer = Foundation.Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(Timer.invokeBlock), userInfo: nil, repeats: false)
    }
    
    func invokeBlock() {
        block()
    }
    
    func terminate() {
        timer?.invalidate()
    }
}
