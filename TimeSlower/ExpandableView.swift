//
//  ExpandableViewProtocol.swift
//  TimeSlower
//
//  Created by Oleksandr Shcherbakov on 5/7/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation
import RxSwift

protocol ExpandableView {
    var expanded: Variable<Bool> { get set }
}