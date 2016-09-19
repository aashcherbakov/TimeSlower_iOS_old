//
//  StateMachine.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 1/31/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/**
A class to perform transition between states. Requires conforming to 
StateMachineDelegate protocol.

Setting state property triggers shouldTransitionFrom and didTransitionFrom 
protocol methods.
*/
class StateMachine <P : StateMachineDelegate> {
    var state: P.StateType {
        get { return privateState }
        set { moveToState(newValue) }
    }
    
    fileprivate unowned let delegate: P
    fileprivate var privateState: P.StateType {
        didSet { delegate.didTransitionFrom(oldValue, to: privateState) }
    }
    
    // Lifecycle
    
    init(withState: P.StateType, delegate: P) {
        privateState = withState
        self.delegate = delegate
    }
    
    // Private Methods
    
    fileprivate func moveToState(_ newValue: P.StateType) {
        if delegate.shouldTransitionFrom(privateState, to: newValue) {
            privateState = newValue
        }
    }
}
