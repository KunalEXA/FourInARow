//
//  Board.swift
//  ConnectFour
//
//  Created by kunal on 7/5/17.
//  Copyright © 2017 kunal. All rights reserved.
//

import Foundation
import GameKit
class Board: NSObject {
    
    // Some constant values that we need
    let countToWin = 4
    static let width = 7
    static let height = 6
    var currentPlayer: Player
    
    // A flattened version of the 2D matrix that represents the FourInARow Game.
    /*
     Things I learned from the below code
     1. Below is the correct way to declare an array as a property and then later initialize it in the class constructor.
        Please see initializer for further details...
    */
    var cells: [Chip]
    
    init(player: Player) {
        // This is what the programmer initializes it to be. Mostly this is going to be a red player.
        currentPlayer = player
        
        /*
         2. One can create an array of repeating number of fixed values using the below syntax.
         3. Following statement is incorrent if used before the initializer
            var cells = [Chip](repeating: Chip.ChipNone, count: BoardWidth * BoardHeight)
            because BoardWidth and BoardHeight have been given values but not initialized unitl this point. So we cannot use these values for initialization before this point.
         */
        cells = Array(repeating: Chip.ChipNone, count: Board.width * Board.height)
        super.init()
    }
    
    
    /// Set chip value at the provided slot in the cells array.
    ///
    /// - Parameters:
    ///   - chip: Player chip value that needs to be set. Chip type.
    ///   - inColumn: tag number of the selected column by user/AI.
    ///   - inRow: empty slot in row determined using nextEmptySlotInColumn function.
    func setChip(chip: Chip, inColumn: Int, inRow: Int) {
        cells[inRow + inColumn * Board.height] = chip
    }
    
    
    /// Checks if the board is full. Helps in determining if there is a draw. This is exposed to the view controller.
    ///
    /// - Returns: True if the board is full and false otherwise.
    func isFull() -> Bool {
        for column in 0..<Board.width {
            if canMoveInColumn(inColumn: column){
                return false
            }
        }
        return true
    }
    
    
    /// Determines if a column has an empty slot to place a chip. This is exposed to view controller.
    ///
    /// - Parameter inColumn: tag number of the button which was selected.
    /// - Returns: True in case of an empty slot else returns false.
    func canMoveInColumn(inColumn: Int) -> Bool {
        return nextEmptySlotInColumn(inColumn: inColumn) >= 0
    }
    
    
    /// Returns next empty slot in the selected column.
    ///
    /// - Parameter inColumn: tag number of selected column
    /// - Returns: row number where the empty slot was found. If no slot was found then returns -1.
    func nextEmptySlotInColumn(inColumn: Int) -> Int {
        for row in 0..<Board.height {
            if chipInColumn(inColumn: inColumn, inRow: row) == .ChipNone {
                return row
            }
        }
        return -1
    }
    
    
    /// Returns chip value at specified slot in the cells array.
    ///
    /// - Parameters:
    ///   - inColumn: Column number representing the 2D array
    ///   - inRow: row number representing the 2D array
    /// - Returns: object of type Chip, namely, ChipRed, ChipBlack, ChipNone.
    func chipInColumn(inColumn: Int, inRow: Int) -> Chip {
        return cells[inRow + inColumn * Board.height]
    }
    
    
    /// Update game state after AI has made its move.
    ///
    /// - Parameter gm: instance of type GKGameModel. Since it is implemented by this class it is actually an instance of this class.
    func updateChipsFromBoard(gm: Board) {
        let columnsData = gm.cells
        // Copy values to cells array
        for index in 0..<columnsData.count {
            cells[index] = columnsData[index]
        }
    }
}

extension Board: GKGameModel {
    
    // return all players in the model
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    
    /// Copies over all data related to the game and helps prevent damage due to any destructive updates.
    ///
    /// - Parameter gameModel: Board object
    func setGameModel(_ gameModel: GKGameModel) {
        if let instance = gameModel as? Board {
            updateChipsFromBoard(gm: instance)
            currentPlayer = instance.activePlayer! as! Player
        }
    }
    
    
    
    /// Provides the game model an array of move objects to decide upon which move to select based on some score.
    ///
    /// - Parameter player: current plaer.
    /// - Returns: array of moves if any. If not then nil.
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        var moves = [Move]()
        // Further consideration required for this action.
        for column in 0..<Board.width {
            if canMoveInColumn(inColumn: column) {
                moves.append(Move(withColumn: column))
            }
        }
        if moves.isEmpty {
            return nil
        } else {
            return moves
        }
    }
    
    
    /// Once AI decides the column to move, find new slot in that column, update slot information and update current player.
    ///
    /// - Parameter gameModelUpdate: should be an object of Move class.
    func apply(_ gameModelUpdate: GKGameModelUpdate){
        if let instance = gameModelUpdate as? Move{
            // Set the required chip
            let row = nextEmptySlotInColumn(inColumn: instance.column)
            setChip(chip: currentPlayer.chip, inColumn: instance.column, inRow: row)
            // update current player. This should mostly not be a problem.
            if let temp = currentPlayer.opponent() {
                currentPlayer = temp
            }
        }
    }
    
    
    /// The aim of this function is to allow game model to create copies of game states.
    /// These copies will then be used by game model to find best move, play its own move and update the state of the game.
    /// zone is present there for historical reasons and does not need to be considered/used in the function.
    /// - Parameter zone: <#zone description#>
    /// - Returns: an instance of type Board in this case. In general the type is any.
    func copy(with zone: NSZone? = nil) -> Any {
        let instance = Board(player: self.currentPlayer)
        instance.setGameModel(self) // Update cells array and player for this new instance
        return instance
    }
    
    
    
    /// Called after every player's turn in continue game func of the view controller.
    ///
    /// - Parameter player: instance of player class
    /// - Returns: Return true if current player has won, else return false.
    func isWin(for player: GKGameModelPlayer) -> Bool {
        if let playerInstance = player as? Player {
            let chip = playerInstance.chip
            for column in 0..<Board.width {
                for row in 0..<Board.height {
                    if countSquaresForWin(column: column, row: row, moveInX: 0, moveInY: 1, playerChip: chip) { return true } // Checking row wise
                    if countSquaresForWin(column: column, row: row, moveInX: 1, moveInY: 0, playerChip: chip) { return true } // Checking column wise
                    if countSquaresForWin(column: column, row: row, moveInX: 1, moveInY: 1, playerChip: chip) { return true } // Checking left diagonal
                    if countSquaresForWin(column: column, row: row, moveInX: 1, moveInY: -1, playerChip: chip) { return true } // checking right diagonal
                }
            }
        }
        return false
    }
    
    
    /// Easiest way to check if the win criteria is satisfied.
    ///
    /// - Parameters:
    ///   - column: column no.
    ///   - row: row no.
    ///   - moveInX: this is for moving along a column. Value will be 1 when moving along a column or diagonally and 0 otherwise.
    ///   - moveInY: for moving along a row. Value will be 1 when moving in a button, 1 for left diagonal and -1 for right diagonal and zero otherwise.
    ///   - playerChip: chip for comparison
    /// - Returns: true if win criteria is satisfied and false otherwise.
    private func countSquaresForWin(column: Int, row: Int, moveInX: Int, moveInY: Int, playerChip: Chip) -> Bool {
        if row + (moveInY * 3) < 0 { return false }
        if row + (moveInY * 3) >= Board.height { return false }
        if column + (moveInX * 3) < 0 { return false }
        if column + (moveInX * 3) >= Board.width { return false }
        
        for i in 0..<countToWin {
            if chipInColumn(inColumn: column + (i * moveInX), inRow: row + (i * moveInY)) != playerChip {return false}
        }
        return true
    }
    
    /// Function that game model uses to determine best move. This is a very trivial implementation though.
    /// This function is important since AI doesn't play without it!!!
    /// - Parameter player: instance denoting current player - red/black.
    /// - Returns: value of 1000/-1000 depending on how the move benefits AI. Returns 0 if there is no incentive for either players.
    func score(for player: GKGameModelPlayer) -> Int {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) {
                return 1000
            } else if isWin(for: playerObject.opponent()!) {
                return -1000
            }
        }
        return 0
    }
}
