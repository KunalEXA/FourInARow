//
//  MinMaxStrategist.swift
//  ConnectFour
//
//  Created by kunal on 7/5/17.
//  Copyright © 2017 kunal. All rights reserved.
//

import Foundation
import GameKit
class Move: NSObject, GKGameModelUpdate {
    
    // To confirm to GKGameModelUpdate we need to just implement a score or value variable. This variable is used for storing move ratings when selecting a move.
    // I've initialized value to zero without harm.
    var value = 0
    var column: Int
    
    init(withColumn: Int) {
        column = withColumn
    }
}
