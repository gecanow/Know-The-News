//
//  ViewController.swift
//  Know The News
//
//  Created by Necanow on 7/9/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

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
    
    var chipHolderArr = [ChipHolder]()
    var optionsArr = [Chip]()
    
    var movable : Int?
    
    var sources = [[String: String]]()
    let apiKey = "bd76ccc886ef4d60bcb5443eebdd6cb4"
    let defaults = UserDefaults.standard
    var savedArticles = [[String:String]]()
    
    var sourceType : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sourceLabel.minimumScaleFactor = 0.1
        sourceLabel.adjustsFontSizeToFitWidth = true

        var query : String!
        if sourceType == "all" {
            query = "https://newsapi.org/v1/sources?language=en&country=us&apiKey=\(apiKey)"
        } else {
            query = "https://newsapi.org/v1/sources?language=en&country=us&category=\(sourceType!)&apiKey=\(apiKey)"
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            [unowned self] in
            // rest of method goes here
            
            if let url = URL(string: query) {
                if let data = try? Data(contentsOf: url) {
                    let json = try! JSON(data: data)
                    if json["status"] == "ok" {
                        self.parse(json: json)
                        return
                    }
                }
            }
            self.loadError()
        }
        
        if let savedData = defaults.object(forKey: savedArticlesID) as? Data {
            if let decoded = try? JSONDecoder().decode([[String: String]].self, from: savedData) {
                savedArticles = decoded
            }
        }
    }
    
    func parse(json: JSON) {
        //print(json["sources"])
        for result in json["sources"].arrayValue {
            let id = result["id"].stringValue
            let name = result["name"].stringValue
            let description = result["description"].stringValue
            
            let source = ["id": id, "name": name, "description": description]
            sources.append(source)
        }
        
        DispatchQueue.main.async {
            [unowned self] in
            self.chooseRandomArticle()
        }
    }
    
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
    
    
    @IBAction func onTappedUpdate(_ sender: Any) {
        clueLabel.isHidden = false
        chooseRandomArticle()
    }
    
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
    
    func chooseRandomArticle() {
        var index = 0
        if sources.count > 1 {
            index = Int(arc4random_uniform(UInt32(sources.count)))
        }
        
        let chosenSource = Source(theSource: sources[index], theApiKey: apiKey)
        chosenArticle = chosenSource.retrieveRandomArticle()
        
        let splitTitle = gamePlayTitle(chosenArticle["title"]!)
        headlineLabel.text = splitTitle[0]
        sourceLabel.text = "\(chosenSource.source["name"]!) reports:"
        descriptionLabel.text = chosenArticle["description"]
        
        wordPlay.updateWord(to: splitTitle[1])
        print("The missing word is: \(wordPlay.wordID!)")
        
        //-------
        removeAll()
        //-------
        let maxWidth = ((optionsView.frame.width-8)/10)-8
        var size = CGSize(width: ((optionsView.frame.width-8)/CGFloat(wordPlay.wordID.count))-8, height: ((optionsView.frame.height-8)/2)-8)
        if size.width > maxWidth {
            size.width = maxWidth
        }
        
        // where the missing word is!
        let totalHalfWidth = (((Int(size.width)+8)*wordPlay.wordID.count)-8)/2
        let startX = (Int(guessView.frame.width)/2) - totalHalfWidth
        let endX = (Int(guessView.frame.width)/2) + totalHalfWidth
        
        var ctr = 0
        for x in stride(from: startX, to: endX, by: Int(size.width)+8) {
            //guessLabel.text! = "_ " + guessLabel.text!
            chipHolderArr.append(createNewChipHolder(atPoint: CGPoint(x: x, y: 16), ofSize: size, atI: ctr))
            ctr += 1
        }
        
        // set up the character guesses
        let set = wordPlay.randomizedCharacterList()
        
        var count = 0
        var y = guessView.frame.height+16
        for _ in 0..<2 {
            var x = optionsView.frame.minX+8
            for _ in 0..<10 {
                optionsArr.append(createNewCharLabel(atPoint: CGPoint(x: x, y: y), ofSize: size, str: String(set[count])))
                count += 1
                x += size.width+8
            }
            y += size.height + 8
        }
    }
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self.gamePlayView)
        for index in 0..<optionsArr.count {
            if optionsArr[index].frame.contains(loc!) {
                movable = index
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let loc = touches.first?.location(in: self.gamePlayView)
        if movable != nil {
            optionsArr[movable!].frame.origin = loc!
        }
    }
    
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
    
    func droppedInPlace(guessIndex: Int) {
        if optionsArr[movable!].holderIndex() != -1 {
            chipHolderArr[guessIndex].removeChip()
        }
        chipHolderArr[guessIndex].setIn(chip: optionsArr[movable!])
    }
    
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
        
        for x in 0..<analysis.count {
            if analysis[x] == 0 {
                chipHolderArr[x].backgroundColor = .red
            } else if analysis[x] == 1 {
                chipHolderArr[x].backgroundColor = .green
            } else {
                chipHolderArr[x].backgroundColor = .white
            }
        }
    }
    
    func gamePlayTitle(_ fromName: String) -> [String] {
        let arr = fromName.split(separator: " ")
        
        if arr.count > 1 {
            var longest = 0
            for wordI in 1..<arr.count {
                if arr[wordI].count > arr[longest].count && !arr[wordI].contains("-") && !arr[wordI].contains("’") {
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
    
    func parseForPunctuation(inWord: String) -> [String] {
        if inWord.contains(".") {
            return ["______.", "\(inWord.prefix(inWord.count-1))"]
        }
        if inWord.contains(",") {
            return ["______,", "\(inWord.prefix(inWord.count-1))"]
        }
        if inWord.contains("’s") || inWord.contains("'s") {
            return ["______’s", "\(inWord.prefix(inWord.count-2))"]
        }
        if inWord.contains(":") {
            return ["______:", "\(inWord.prefix(inWord.count-1))"]
        }
        if inWord.contains("?") {
            return ["______?", "\(inWord.prefix(inWord.count-1))"]
        }
        if (inWord.prefix(1) == "'" && inWord.suffix(1) == "'") ||
            (inWord.prefix(1) == "\"" && inWord.suffix(1) == "\"") {
            let char = inWord.prefix(1)
            var changed = inWord.prefix(inWord.count-1)
            changed = changed.suffix(changed.count-1)
            return ["\(char)______\(char)", "\(changed)"]
        }
        return ["______", inWord]
    }
    
    @IBAction func onTappedClueView(_ sender: UITapGestureRecognizer) {
        clueLabel.isHidden = !clueLabel.isHidden
    }
    
    func alertUser(_ withTitle: String) {
        let alert = UIAlertController(title: withTitle, message: "", preferredStyle: .alert)
        
        let saveArticle = UIAlertAction(title: "Save and Continue", style: .default) { (void) in
            self.savedArticles.append(self.chosenArticle)
            self.saveSaved()
            self.onTappedUpdate(self)
        }
        
        let next = UIAlertAction(title: "Continue", style: .default) { (void) in
            self.onTappedUpdate(self)
        }
        
        alert.addAction(next)
        alert.addAction(saveArticle)
        present(alert, animated: true, completion: nil)
    }
    
    func saveSaved() {
        if let encoded = try? JSONEncoder().encode(savedArticles) {
            defaults.set(encoded, forKey: savedArticlesID)
        }
    }
}

