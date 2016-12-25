//
// Created by Oleksandr Shcherbakov on 12/3/16.
// Copyright (c) 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Data structure to group average success, results and saved time in given activity.
public struct Stats {

    public init(averageSuccess: Double, totalTimeSaved: Double, totalResults: Int) {
        self.averageSuccess = averageSuccess
        self.totalTimeSaved = totalTimeSaved
        self.totalResults = totalResults
    }
    
    public let averageSuccess: Double
    public let totalTimeSaved: Double
    public let totalResults: Int

}
