//
//  ObservableControlCell.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 7/3/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import ReactiveCocoa

/**
 *  Cell that contains ObservableControl as subview and alows to subscribe to value changes and touches
 */
protocol ObservableControlCell {
    
    /// ObservableControl subclass
    weak var control: ObservableControl! { get }
    
    /**
     Returns SignalProducer that fires every time value did change. Has default implementation that gets
     signal from control instance method valueSingnal() that must be overridden by concrete class.
     
     - returns: SignalProducer with selected value
     */
    func signalForValueChange() -> SignalProducer<AnyObject?, NSError>?
}

extension ObservableControlCell {
    func signalForValueChange() -> SignalProducer<AnyObject?, NSError>? {
        return control.valueSignal()
    }
}

class ObservableControl: UIControl {
    func valueSignal() -> SignalProducer<AnyObject?, NSError>? {
        fatalError("Must be overridden")
    }
    
    func setInitialValue(value: AnyObject?) {
        fatalError("Must be overridden")
    }
}