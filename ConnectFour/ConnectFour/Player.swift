//
//  Player.swift
//  ConnectFour
//
//  Created by kunal on 7/5/17.
//  Copyright © 2017 kunal. All rights reserved.
//

import Foundation
import UIKit
import GameKit

// create an enum called Chip that contains chip values. For the enum to have raw values it must have a type. Going with what was already in place I am using Int.
enum Chip: Int {
    case ChipNone = 0
    case ChipRed
    case ChipBlack
}

class Player: NSObject {
    var chip: Chip
    var color: UIColor
    static var allPlayers = [Player]()
    
    
    /// Initialize the current instance of Player with chip and color values.
    ///
    /// - Parameter playerColor: Chip color of the human player. There is no default specified here but it should be red.
    init(playerColor: String) {
        if(playerColor == "red") {
            chip = .ChipRed
            color = UIColor.red
        } else {
            chip = .ChipBlack
            color = UIColor.black
        }
        super.init()
    }
    
    
    /// This is more of an experiement with convenience initializer. This code initializes allPlayers static array for use for all instances of Player class.
    ///
    /// - Parameter player: Color of the human player. There is no default specified here but it should be red.
    convenience init(player: String) {
        
        // Only create this once for all instances of Player
        if Player.allPlayers.isEmpty {
            /*
                There were a couple of issues that I faced with the code below.
                First, allPlayers is a static array and hence must only be accessed using Player class
                Second, this convenience initializer is not necessary. This can be done in the first initializer itself. This is an experimental use and in some way also to make the code more readable.
                Third, self.init does not work in the below case. That is because self.init results in a delegation and delegations cannot be done in expressions(assignment is an expression).
             */
            Player.allPlayers.append(Player(playerColor: "red"))
            Player.allPlayers.append(Player(playerColor: "black"))
        }
        self.init(playerColor: player)
    }
    
    
    /// Function that returns opponent player for the current player. In case chip is neither black nor red it returns nil and hence has an optional return value
    ///
    /// - Returns: An object of Player class that contains information about player chip and UIColor
    func opponent() -> Player? {
        switch(self.chip) {
        case .ChipRed:
            return blackPlayer()
        case .ChipBlack:
            return redPlayer()
        default:
            return nil
        }
    }
    
    
    /// Function that returns a string used for denoting current player
    ///
    /// - Returns: Red, Black or None in case chip value is .ChipNone
    func name(chip: Chip) -> String {
        switch(chip) {
        case .ChipRed:
            return "Red"
        case .ChipBlack:
            return "Black"
        default:
            return "None"
        }
    }
    
    /// Returns an Player object for player with black chip
    ///
    /// - Returns: Player object with information about black chip.
    private func blackPlayer() -> Player {
        return Player.allPlayers[Chip.ChipBlack.rawValue - 1]
    }
    
    /// Returns an Player object for player with red chip
    ///
    /// - Returns: Player object with information about red chip.
    private func redPlayer() -> Player {
        return Player.allPlayers[Chip.ChipRed.rawValue - 1]
    }
}

extension Player: GKGameModelPlayer {
    // An identifier that helps the system differentiate between players.
    var playerId: Int {
        return chip.rawValue
    }
}
