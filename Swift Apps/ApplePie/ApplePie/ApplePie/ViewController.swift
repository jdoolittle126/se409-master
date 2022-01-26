//
//  ViewController.swift
//  ApplePie
//
//  Created by Doolittle, Jonathan J on 1/19/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var correctWordLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var letterButtons: [UIButton]!
    
    var listOfWords = ["apples", "jellyfish", "gandalf", "helicopter", "kardashian", "alligator", "computer"]
    let incorrectMovesAllowed = 7
    
    var totalWins = 0 {
        didSet {
            newRound()
        }
    }
    var totalLosses = 0 {
        didSet {
            newRound()
        }
    }
    
    var currentGame: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newRound()
    }
    
    func enableLetterButtons(_ enable: Bool) {
        for button in letterButtons {
            button.isEnabled = enable
        }
    }
    
    func newRound() {
        
        if !listOfWords.isEmpty {
            enableLetterButtons(true)
            let newWord = listOfWords.removeFirst()
            currentGame = Game(word: newWord, incorrectMovesRemaining: incorrectMovesAllowed)
            updateUi()
        } else {
            enableLetterButtons(false)
        }
        

    }
    
    func updateUi() {
        var letters = [String]()
        
        for letter in currentGame.formattedWord {
            letters.append(String(letter))
        }
        
        let wordWithSpacing = letters.joined(separator: " ")
    
        
        scoreLabel.text = "Wins: \(totalWins) Losses: \(totalLosses)"
        correctWordLabel.text = wordWithSpacing
        treeImageView.image = UIImage(named: "Tree \(currentGame.incorrectMovesRemaining)")
    }

    func updateGameState() {
        if currentGame.incorrectMovesRemaining == 0 {
            totalLosses += 1
        } else if currentGame.word == currentGame.formattedWord {
            totalWins += 1
        } else {
            updateUi()
        }
    }
    
    @IBAction func letterButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        let letterString = sender.titleLabel?.text
        
        if letterString == nil {
            return
        }
        
        let letter = Character((letterString?.first?.lowercased())!)
        
        currentGame.playerGuessed(letter: letter)
        updateGameState()
    }
    
}

