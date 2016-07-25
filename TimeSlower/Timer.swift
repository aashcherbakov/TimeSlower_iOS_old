//
//  Timer.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/24/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

internal class Timer: NSObject {
    private let block: () -> Void
    private var timer: NSTimer?
    private let interval: Double
    
    init(_ interval: Double, block: () -> ()) {
        self.block = block
        self.interval = interval
    }
    
    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(Timer.invokeBlock), userInfo: nil, repeats: false)
    }
    
    func invokeBlock() {
        block()
        print("timer ticked")
    }
    
    func terminate() {
        timer?.invalidate()
    }
}