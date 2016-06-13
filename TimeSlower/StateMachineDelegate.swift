//
//  StateMachineDelegate.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 2/6/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Protocol to communicate with State Machine instance
protocol StateMachineDelegate: class {
    
    /// typealias representing enum of states
    associatedtype StateType
    
    /**
     Delegate method with which you perform initial setup of StateMachine:
     what changes of state are alowed. Example:
     
     func shouldTransitionFrom(from: StateType, to: StateType) -> Bool {
     switch (from, to) {
     - case (.NoData, .Name): return true
     - case (.Name, .BasisAndStartTime): return true
     - case (.BasisAndStartTime, .FullHouse): return true
     - default: return false
     }
     
     - parameter from: current StateType
     - parameter to:   next StateType
     
     - returns: true if transition is legal.
     */
    func shouldTransitionFrom(from: StateType, to: StateType) -> Bool
    
    /**
     Delegate method called when the state changed. You should perform actions with
     your views and data here.
     
     - parameter from: current StateType
     - parameter to:   next StateType
     */
    func didTransitionFrom(from: StateType, to: StateType)
}