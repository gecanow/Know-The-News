//
//  ViewController.swift
//  Know The News
//
//  Created by Necanow on 7/9/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

let titleAttributes = [NSAttributedStringKey.font: UIFont(name: "Sofija", size: 30)!]

class ViewController: UIViewController {
    
    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var wordPlay = WordPlay()
    var chosenArticle : [String : String]!
    
    @IBOutlet weak var gamePlayView: UIView!
    @IBOutlet weak var guessView: UIView!
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet weak var gameTimer: GameTimer!
    
    var chipHolderArr = [ChipHolder]()
    var optionsArr = [Chip]()
    
    var movable : Int?
    
    var articles : [[String: String]]!
    
    let defaults = UserDefaults.standard
    var savedArticles = [[String:String]]()
    
    //=========================================
    // VIEW DID LOAD
    //=========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceLabel.minimumScaleFactor = 0.1
        sourceLabel.adjustsFontSizeToFitWidth = true
        
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
        
        if let savedData = defaults.object(forKey: savedArticlesID) as? Data {
            if let decoded = try? JSONDecoder().decode([[String: String]].self, from: savedData) {
                savedArticles = decoded
            }
        }
        // start the game!
        self.onTappedUpdate(self)
    }
    
    //=========================================
    // Informs the user of a loading error
    //=========================================
    func loadError() {
        DispatchQueue.main.async {
            [unowned self] in
            //(rest of method goes here)

            let alert = UIAlertController(title: "Loading Error",
                                          message: "There was a problem loading the news feed",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //===========================================
    // Retrieves new article when user taps next
    //===========================================
    @IBAction func onTappedUpdate(_ sender: Any) {
        clueLabel.isHidden = false
        self.gameTimer.reset()
        chooseRandomArticle()
    }
    
    //=========================================
    // Removes all the chips and chip holders
    //=========================================
    func removeAll() {
        while !chipHolderArr.isEmpty {
            let holder = chipHolderArr[0]
            holder.removeFromSuperview()
            chipHolderArr.remove(at: 0)
        }
        
        while !optionsArr.isEmpty {
            let option = optionsArr[0]
            option.removeFromSuperview()
            optionsArr.remove(at: 0)
        }
    }
    
    //=========================================
    // Chooses a random article from a random
    // source and removes the longest word from
    // that article's headline
    //=========================================
    func chooseRandomArticle() {
        var index = 0
        if articles.count > 1 {
            print("LOADING FROM ARTICLES")
            index = Int(arc4random_uniform(UInt32(articles.count)))
            chosenArticle = articles[index]
            
            let splitTitle = gamePlayTitle(chosenArticle["title"]!)
            headlineLabel.text = splitTitle[0]
            sourceLabel.text = "\(chosenArticle["sourceName"]!) reports:"
            descriptionLabel.text = chosenArticle["description"]
            
            wordPlay.updateWord(to: splitTitle[1], fromArticle: chosenArticle)
            print("The missing word is: \(wordPlay.wordID!)")
            
            //-------
            setUpChips()
        } else {
            self.loadError()
        }
    }
    
    //=========================================
    // Sets up and displays the chips and the
    // chip holders
    //=========================================
    func setUpChips() {
        removeAll()
        
        //-------
        let cols = CGFloat(7.0)
        let rows = CGFloat(3.0)
        let space = CGFloat(8.0)
        //-------
        
        //-------
        let maxWidth = ((optionsView.frame.width-space)/cols)-space
        var size = CGSize(width: ((optionsView.frame.width-space)/CGFloat(wordPlay.wordID.count))-space, height: ((optionsView.frame.height-space)/rows)-space)
        
        if size.width > maxWidth { size.width = maxWidth }
        //-------
        
        // CHARACTER HOLDERS
        var totalHalfWidth = (((Double(size.width + space)) * Double(wordPlay.wordID.count))-Double(space))/2
        var startX = (Double(guessView.frame.width)/2) - totalHalfWidth
        
        var x = startX
        for ctr in 0..<wordPlay.wordID.count {
            chipHolderArr.append(createNewChipHolder(atPoint: CGPoint(x: x, y: 16), ofSize: size, atI: ctr))
            x += Double(size.width+space)
        }
        
        // CHIP OPTIONS
        totalHalfWidth = Double((size.width + space) * cols - space)/2
        startX = (Double(optionsView.frame.width)/2) - totalHalfWidth
        
        let set = wordPlay.randomizedCharacterList(length: Int(rows*cols))
        
        var count = 0
        var y = guessView.frame.height+16
        for _ in 0..<Int(rows) {
            var x = CGFloat(startX) + space
            for _ in 0..<Int(cols) {
                optionsArr.append(createNewCharLabel(atPoint: CGPoint(x: x, y: y), ofSize: size, str: String(set[count])))
                count += 1
                x += size.width + space
            }
            y += size.height + space
        }
        
        // OFFICIALLY START THE GAME
        gameTimer.start()
    }
    
    //==========================================
    // 1 - creates new character labels (chips)
    // 2 - creates new chip holders
    //==========================================
    func createNewCharLabel(atPoint: CGPoint, ofSize: CGSize, str: String) -> Chip {
        let b = Chip(atPoint: atPoint, ofSize: ofSize, str: str)
        gamePlayView.addSubview(b)
        gamePlayView.bringSubview(toFront: b)
        return b
    }
    func createNewChipHolder(atPoint: CGPoint, ofSize: CGSize, atI: Int) -> ChipHolder {
        let b = ChipHolder(atPoint: atPoint, ofSize: ofSize, index: atI)
        gamePlayView.addSubview(b)
        gamePlayView.bringSubview(toFront: b)
        return b
    }
    
    //=========================================
    // TOUCHES BEGAN
    // Sets movable? to the tapped chip
    //=========================================
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self.gamePlayView)
        for index in 0..<optionsArr.count {
            if optionsArr[index].frame.contains(loc!) {
                movable = index
                break
            }
        }
    }
    
    //=========================================
    // TOUCHES MOVED
    // If movable isn't nil, move it
    //=========================================
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self.gamePlayView)
        if movable != nil {
            optionsArr[movable!].frame.origin = loc!
        }
    }
    
    //=========================================
    // TOUCHES ENDED
    // Either place movable in a chip holder
    // or send it back home.
    //=========================================
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self.gamePlayView)
        
        if movable != nil {
            var foundProperPlace = false
            for guessIndex in 0..<chipHolderArr.count {
                if chipHolderArr[guessIndex].frame.contains(loc!) {
                    droppedInPlace(guessIndex: guessIndex)
                    foundProperPlace = true
                    break
                }
            }
            
            if !foundProperPlace {
                if optionsArr[movable!].holderIndex() != -1 {
                    chipHolderArr[optionsArr[movable!].holderIndex()].removeChip()
                }
                optionsArr[movable!].frame.origin = optionsArr[movable!].home
            }
            
            checkForCompletion()
        }
        movable = nil
    }
    
    //=========================================
    // Handles when a chip is dropped into a
    // chip holder.
    //=========================================
    func droppedInPlace(guessIndex: Int) {
        if optionsArr[movable!].holderIndex() != -1 {
            chipHolderArr[optionsArr[movable!].holderIndex()].removeChip()
        }
        chipHolderArr[guessIndex].setIn(chip: optionsArr[movable!])
    }
    
    //=========================================
    // Checks for completion of puzzle.
    //  0 - wrong chip placement
    //  1 - right chip placement
    // -1 - empty chip holder
    //=========================================
    func checkForCompletion() {
        
        var wordGuess = [String]()
        for holder in chipHolderArr {
            if holder.myChip == nil {
                wordGuess += [" "]
            } else {
                wordGuess += [holder.myChip!.text!]
            }
        }
        
        let analysis = wordPlay.analyze(word: wordGuess)
        var completed = true
        
        for x in 0..<analysis.count {
            if analysis[x] == 0 {
                chipHolderArr[x].backgroundColor = .red
                completed = false
            } else if analysis[x] == 1 {
                chipHolderArr[x].backgroundColor = .green
            } else {
                chipHolderArr[x].backgroundColor = .white
                completed = false
            }
        }
        
        if completed {
            // END THE GAME
            gameTimer.stop()
            
            let source = wordPlay.article["sourceName"]
            let date = wordPlay.article["date"]
            let fullTitle = wordPlay.article["title"]
            alertUser("You got it! On \(date!), \(source!) published \n\"\(fullTitle!)\"")
        }
    }
    
    //=========================================
    // Responsible for retrieving the longest
    // word from a title. Returns arr where:
    // - index 0 is title without a word
    // - index 1 is the missing word
    //=========================================
    func gamePlayTitle(_ fromName: String) -> [String] {
        let arr = fromName.split(separator: " ")
        
        if arr.count > 1 {
            var longest = 0
            for wordI in 1..<arr.count {
                if arr[wordI].count > arr[longest].count && !arr[wordI].contains("-") && !arr[wordI].contains("’") && arr[wordI].count < 12 {
                    longest = wordI
                }
            }
            
            let replacementAndReal = parseForPunctuation(inWord: String(arr[longest]))
            let replacement = replacementAndReal[0]
            let missingWord = replacementAndReal[1]
            
            var outputString = ""
            for wordI in 0..<arr.count {
                if wordI == longest {
                    outputString += "\(replacement) "
                } else {
                    outputString += arr[wordI] + " "
                }
            }
            return [outputString, missingWord]
        }
        return ["", ""]
    }
    
    //=========================================
    // Parses the missing word for punctuation
    //=========================================
    func parseForPunctuation(inWord: String) -> [String] {
        let length = inWord.count
        
        if inWord.contains(".") ||
            inWord.contains(",") ||
            inWord.contains(":") ||
            inWord.contains("?") {
            let finalChar = inWord.suffix(1)
            return ["______\(finalChar)", "\(inWord.prefix(length-1))"]
        }
        if inWord.contains("’s") || inWord.contains("'s") {
            return ["______’s", "\(inWord.prefix(length-2))"]
        }
        if (inWord.prefix(1) == "'" && inWord.suffix(1) == "'") ||
            (inWord.prefix(1) == "\"" && inWord.suffix(1) == "\"") {
            let char = inWord.prefix(1)
            var changed = inWord.prefix(length-1)
            changed = changed.suffix(changed.count-1)
            return ["\(char)______\(char)", "\(changed)"]
        }
        if inWord.prefix(2) == "r/" {
            return ["r/______", "\(inWord.suffix(length-2))"]
        }
        return ["______", inWord]
    }
    
    //=========================================
    // Reveals of hides the clue
    //=========================================
    @IBAction func onTappedClueView(_ sender: UITapGestureRecognizer) {
        clueLabel.isHidden = !clueLabel.isHidden
    }
    
    //=========================================
    // Alerts the user of a win and gives the
    // option to continue or save and continue
    //=========================================
    func alertUser(_ withTitle: String) {
        let alert = UIAlertController(title: withTitle, message: "If you would like to save this article to your library, select 'Save and Continue'", preferredStyle: .alert)
        
        let saveArticle = UIAlertAction(title: "Save and Continue", style: .default) { (void) in
            self.savedArticles.append(self.chosenArticle)
            self.saveSaved()
            
            self.onTappedUpdate(self)
        }
        
        let next = UIAlertAction(title: "Continue to Next Article", style: .default) { (void) in
            self.onTappedUpdate(self)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(next)
        alert.addAction(saveArticle)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    //=========================================
    // Saves the saved articles to defaults
    //=========================================
    func saveSaved() {
        if let encoded = try? JSONEncoder().encode(savedArticles) {
            defaults.set(encoded, forKey: savedArticlesID)
        }
    }
}

