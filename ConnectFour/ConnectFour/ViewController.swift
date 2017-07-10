//
//  ViewController.swift
//  ConnectFour
//
//  Created by kunal on 7/4/17.
//  Copyright © 2017 kunal. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {

    /*
        Following are the things I learned from below code
        1. Lazy properties always need an initializer. We cannot leave them declared and define them later.
        2. There are several ways to do this. One is chaining this with computed properties as done below. Like I have chained strategist with stragiestInstance.
        3. Another way would be to use some function to instantiate the value sometime later in the code...like on view did load or something.
        4. However both these options make use of self which has a strong reference. It might lead to a strong reference to itself.
            ViewController -> strategist -> strategistInstance -> ViewController.
            Need to check if this could be a problem later in the future.
        5. We can also use optionals to instantiate the items later.
    */
    var strategist: GKMinmaxStrategist!
    var board: Board!
    var chipLayers:[[CAShapeLayer]] = []
    
    // create an outlet collection for buttons
    @IBOutlet var columnButtons: [UIButton]!
    
    var chipPath: UIBezierPath!
    
    /// This function is called only once. Hence this is the perfect place to initialize strategist class and reset board.
    override func viewDidLoad() {
        super.viewDidLoad()
        strategist = GKMinmaxStrategist()
        
        //Set how many look aheads you want and tie breaker mechanism.
        strategist.maxLookAheadDepth = 7
        strategist.randomSource = GKARC4RandomSource()
        
        // Initialize chipLayer
        for _ in 0..<Board.width {
            chipLayers.append([CAShapeLayer]())
        }
        
        // Reset Board
        resetBoard()
    }
    
    
    /// This function helps when orientation of screen changes.
    /// When switching between portrait and landscape, the bounds and path of chips need to be recomputed.
    /// That is why is function is being used.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let button = columnButtons[0]
        let length: CGFloat = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x:0, y:0, width:length, height:length)
        chipPath = UIBezierPath(ovalIn: rect) // Create a UIBeizerPath object with an oval path in the specified rectangle.

        for (column, value) in chipLayers.enumerated() {
            for(row, chip) in value.enumerated() {
                chip.path = chipPath?.cgPath
                chip.frame = (chipPath?.bounds)!
                chip.position = positionForChipLayersAtColumn(column: column, row: row)
            }
        }
    }

    
    /// This function is called when user clicks on a button.
    /// It checks if we are allowed to place a chip in the selected column, add chip to cells array then proceed to update button and game state.
    /// - Parameter sender: button that user clicked
    @IBAction func makeAMove(_ sender: UIButton) {
        let tag = sender.tag
        if board.canMoveInColumn(inColumn: tag) { // Cannot proceed if the column is already full.
            let row = board.nextEmptySlotInColumn(inColumn: tag)
            board.setChip(chip: board.currentPlayer.chip, inColumn: tag, inRow: row)
            addChipLayerAtColumn(inColumn: tag, atRow: row, color: board.currentPlayer.color)
            continueGame()
        }
    }
    
    
    /// This function is called when initializing board and also when a game restarts.
    /// This creates a new board object and resets UI.
    private func resetBoard() {
        // Create new object of board
        board = Board(player: Player(player: "red"))
        
        // Set game model for use
        strategist.gameModel = board
        
        // Update UI
        updateUI()
        
        /* There is a difference between the below and code that works
         for var column in chipLayers {
         for chip in chipLayers {
         chip.removeFromSuperLayer()
         }
         column.removeAll(keepingCapacity: true)
         }
         
         This code seems to work in a way similar to the one above. But it does not reset chipLayers array.
         It seems like this creates a temporary column array and then operates on it.
         It also makes sense because whenever we are modifying contents of an array they are copied first and then operated upon.
         */
        
        // remove all chipLayers from UI.
        // to make column mutable I have used a var over here.
        for i in 0..<Board.width {
            for chip in chipLayers[i] {
                chip.removeFromSuperlayer()
            }
            chipLayers[i].removeAll()
        }
    }
    
    
    /// Makes use of UIBeizerPath and CAShapeLayer to create a chip at a specified position in the UI.
    ///
    /// - Parameters:
    ///   - inColumn: button tag number where chip is to be placed.
    ///   - AtRow: row in which chip is to be placed.
    ///   - color: current player color.
    private func addChipLayerAtColumn(inColumn: Int, atRow: Int, color: UIColor) {
        if chipLayers[inColumn].count < atRow + 1 {
            let chip = CAShapeLayer()
            chip.path = chipPath.cgPath
            chip.frame = (chipPath.bounds)
            chip.fillColor = color.cgColor
            chip.position = positionForChipLayersAtColumn(column: inColumn, row: atRow)
            
            view.layer.addSublayer(chip)
            let animation = CABasicAnimation(keyPath: "position.y")
            animation.fromValue = -chip.frame.size.height
            animation.toValue = chip.position.y
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            chip.add(animation, forKey: nil)
            chipLayers[inColumn] = chipLayers[inColumn] + [chip]
        }
    }
    
    
    /// Compute corresponding point on screen where the chip is to be displayed.
    ///
    /// - Parameters:
    ///   - column: Button tag
    ///   - row: row number in the column
    /// - Returns: a CGPoint the one could use to display chip on the screen.
    private func positionForChipLayersAtColumn(column: Int, row: Int) -> CGPoint {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        let xOffset = button.frame.midX
        var yOffset = button.frame.maxY + size / 3
        yOffset -= size * CGFloat(row)
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    
    /// Called after each player's turn. 
    /// Helps decide if the game is over, has either player won and if not then update the current player.
    private func continueGame() {
        var gameTitle: String? = nil
        if(board.isWin(for: board.currentPlayer)) {
            gameTitle = "\(board.currentPlayer.name(chip: board.currentPlayer.chip)) wins"
        } else if(board.isFull()) {
            gameTitle = "Draw!!!"
        }
        
        // We need to display the above message in a alert.
        if gameTitle != nil {
            let alert = UIAlertController(title: gameTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { [unowned self] (action) in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            present(alert, animated: true)
            return
        }
        board.currentPlayer = board.currentPlayer.opponent()!
        updateUI()
    }
    
    
    /// Updates title, navigation bar color based on currentplayer and calls AIMove if opponent is playing.
    private func updateUI() {
        // Update title
        title = "\(board.currentPlayer.name(chip: board.currentPlayer.chip))'s Turn"
        navigationController?.navigationBar.backgroundColor = board.currentPlayer.color
        if board.currentPlayer.chip == Chip.ChipBlack {
            aiMove()
        }
    }
    
    
    /// Wrapper function to initiate, determine and complete AI move.
    /// Creates spinner, finds best move for AI and moves chip in specified column.
    private func aiMove() {
        // Diable all buttons first
        columnButtons.forEach { $0.isEnabled = false }
        // spinner
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner) // add spinner to navBar
        
        
        // Fo non-blocking purposes we'll put this into another queue and later dispatch to main queue for UI.
        DispatchQueue.global().async { [weak self] in
            let time = CFAbsoluteTimeGetCurrent()
            if let columnForAIMove = self?.columnForAIMove() {
                let timeToFindMove = CFAbsoluteTimeGetCurrent() - time
                let upperLimitTime = 2.0
                let delay = min(upperLimitTime - timeToFindMove, timeToFindMove)
                // Dispatch to main queue after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self?.makeAIMove(inColumn: columnForAIMove)
                }
            }
        }
    }
    
    
    /// Function that fetches best move for AI based on minmax strategist.
    /// Internally calls bestMove strategist function.
    /// If the object returned is of move type then we make the move.
    /// - Returns: <#return value description#>
    private func columnForAIMove() -> Int? {
        // Find best move using strategist
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
             return aiMove.column
        }
        return nil
    }
    
    /// Function similar to makeAMove only on the AI side.
    ///
    /// - Parameter inColumn: an int value specifying the button in which we need to move black chip.
    private func makeAIMove(inColumn: Int) {
        navigationItem.leftBarButtonItem = nil // This removes the spinner
        
        if board.canMoveInColumn(inColumn: inColumn) {
            let row = board.nextEmptySlotInColumn(inColumn: inColumn)
            board.setChip(chip: board.currentPlayer.chip, inColumn: inColumn, inRow: row)
            addChipLayerAtColumn(inColumn: inColumn, atRow: row, color: board.currentPlayer.color)
            columnButtons.forEach{ $0.isEnabled = true }
            continueGame()
        }
    }
}

