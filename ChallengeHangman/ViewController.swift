//
//  ViewController.swift
//  ChallengeHangman
//
/// Hangman
/// This is a game that will provide a grid of 26 letters to the user
/// They can press each letter as many times as they wish
/// but they only get 7 incorrect guesses before they hang themselves
/// The top will progress thru seven images that end up with the hanging
///
/// A list of potential words will be loaded from the disk, and a random word will be chosen
/// to guess.  The number of letters in the game will be used to present a guess area
/// and correct letters will be filled in as they are chosen.
///
/// Potential HangMan design
///  -----
///  |        |
///  |       o
///  |      /|\
///  |       |
///  |     /  \
///  |
///  ======
//  Created by Michael Rowe on 6/11/22.
//

import UIKit

class ViewController: UIViewController {
    var scoreLabel: UILabel!
    var guessLabel: UILabel!
    var hangManLabel: UILabel!
    var letterButtons = [UIButton]()

    var usedLetters = [String]()
    var solution = ""
    var currentGuess = ""
    var hangText = """
            ---------
            |       |
            |
            |
            |
            |
            |
            ===========
            """

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var badGuesses = 0
    let alphabet = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

    var words = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Let's build the View in code
        view = UIView()
        view.backgroundColor = .blue

        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)

        hangManLabel = UILabel()
        hangManLabel.translatesAutoresizingMaskIntoConstraints = false
        hangManLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        hangManLabel.textAlignment = .left
        hangManLabel.numberOfLines = 0
        hangManLabel.font = UIFont(name: "Courier New", size: 16)
        hangManLabel.text = hangText
        view.addSubview(hangManLabel)

        guessLabel = UILabel()
        guessLabel.translatesAutoresizingMaskIntoConstraints = false
        guessLabel.font = UIFont.systemFont(ofSize: 36)
        guessLabel.textAlignment = .center
        guessLabel.text = "Nope"
        view.addSubview(guessLabel)

        let letterButtonsView = UIView()
        letterButtonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(letterButtonsView)


        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            hangManLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10),
            hangManLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            guessLabel.topAnchor.constraint(equalTo: hangManLabel.bottomAnchor, constant: 50),
            guessLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            letterButtonsView.widthAnchor.constraint(equalToConstant: 925),
            letterButtonsView.heightAnchor.constraint(equalToConstant: 320),
            letterButtonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            letterButtonsView.topAnchor.constraint(equalTo: guessLabel.bottomAnchor, constant: 20),
            letterButtonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)

            // add a Restart Button Top Left
        ])

        let width = 74
        let height = 40

        for row in 0..<2 {
            for column in 0..<13 {
                let letterButton = UIButton(type: .system)
                var addition = column
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                // a bit of a hack I know
                if row == 1 {
                    addition += 12
                }
                letterButton.setTitle("\(alphabet[row+addition])", for: .normal)
                letterButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                letterButton.layer.borderWidth = 2
                letterButton.layer.borderColor = UIColor.gray.cgColor

                letterButtonsView.addSubview(letterButton)

                letterButtons.append(letterButton)
            }
        }
        // lastly let's load potential words array from file
        loadWords()

    }

    func loadWords() {
        if let wordsFileURL = Bundle.main.url(forResource: "wordlist", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: wordsFileURL) {
                words = levelContents.components(separatedBy: "\n")
                words.shuffle()
            }
        }
        startGame()
    }

    func startGame() {
        solution = words.randomElement() ?? "Nope"
        var promptWord = ""
        for _ in solution {
            promptWord += "?"
        }
        print("Solutions = \(solution)")
        guessLabel.text = promptWord
    }

    func restartGame(action: UIAlertAction) {
        badGuesses = 0
        hangManLabel.text = hangText
        usedLetters.removeAll()

        for button in letterButtons {
            button.isHidden = false
        }
        startGame()
    }

    func quitGame(action: UIAlertAction) {
        exit(0)
    }

    @objc func buttonPressed(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }

        usedLetters.append(buttonTitle)
        var promptWord = ""

        for letter in solution {
            let strLetter = String(letter).lowercased()

            if usedLetters.contains(strLetter) {
                promptWord += strLetter
            } else {
                promptWord += "?"
            }
        }

        sender.isHidden = true

        if promptWord == solution {
            //
            score += 1
            let ac = UIAlertController(title: "Yeah!", message: "You won! Want to play another game?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Let's Go!", style: .default, handler: restartGame))
            ac.addAction(UIAlertAction(title: "Nope", style: .cancel, handler: quitGame))
            present(ac, animated: true)
        } else {
            if !solution.contains(buttonTitle) {
                badGuesses += 1
                hangManLabel.text = hangedMan(badGuesses: badGuesses)
                if badGuesses >= 7 {
                    let ac = UIAlertController(title: "You lost!", message: "Let's play another game.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Let's Go!", style: .default, handler: restartGame))
                    present(ac, animated: true)
                }
            }
        }
        currentGuess = promptWord
        guessLabel.text = promptWord
    }

    func hangedMan(badGuesses: Int) -> String {
        switch badGuesses {
        case 0:
            return """
            ---------
            |       |
            |
            |
            |
            |
            |
            ===========
            """
        case 1:
            return """
            ---------
            |       |
            |       o
            |
            |
            |
            |
            ===========
            """
        case 2:
            return """
            ---------
            |       |
            |       o
            |       |
            |
            |
            |
            ===========
            """
        case 3:
            return """
            ---------
            |       |
            |       o
            |      /|
            |
            |
            |
            ===========
            """
        case 4:
            return """
            ---------
            |       |
            |       o
            |      /|\
            |
            |
            |
            ===========
            """
        case 5:
            return """
            ---------
            |       |
            |       o
            |      /|\
            |       |
            |
            |
            ===========
            """
        case 6:
            return """
            ---------
            |       |
            |       o
            |      /|\
            |       |
            |      /
            |
            ===========
            """
        case 7:
            return """
            ---------
            |       |
            |       o
            |      /|\
            |       |
            |      / \
            |
            ===========
            """
        default:
            return """
            ---------
            |       |
            |
            |
            |
            |
            |
            ===========
            """
        }
    }
}
