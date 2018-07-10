//
//  ViewController.swift
//  Know The News
//
//  Created by Necanow on 7/9/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WordPlayDelegate {
    
    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var wordPlay = WordPlay()
    
    var sources = [[String: String]]()
    let apiKey = "5d892509a49046a087917c466fa80d09"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordPlay.delegate = self
        
        let query = "https://newsapi.org/v1/sources?language=en&country=us&apiKey=\(apiKey)"
        
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
    }
    
    func loadUpOptions(selection: [String]) {
        DispatchQueue.main.async {
            var arr = selection
            for index in stride(from: 3, through: 0, by: -1) {
                let rand = Int(arc4random_uniform(UInt32(index+1)))
                self.buttons[index].setTitle(arr[rand], for: .normal)
                arr.remove(at: rand)
            }
        }
    }
    
    func parse(json: JSON) {
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
        clueLabel.isHidden = true
        chooseRandomArticle()
    }
    
    func chooseRandomArticle() {
        let index = Int(arc4random_uniform(UInt32(sources.count - 1)))
        let chosenSource = Source(theSource: sources[index], theApiKey: apiKey)
        let myArticle = chosenSource.retrieveRandomArticle()
        
        let splitTitle = gamePlayTitle(myArticle["title"]!)
        headlineLabel.text = splitTitle[0]
        sourceLabel.text = "\(chosenSource.source["name"]!) reports:"
        descriptionLabel.text = myArticle["description"]
        
        wordPlay.updateWord(to: splitTitle[1])
        print("The missing word is: \(wordPlay.wordID)")
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
        return [String(arr[0]), String(arr[0])]
    }
    
    func parseForPunctuation(inWord: String) -> [String] {
        if inWord.contains(".") {
            return ["______.", "\(inWord.prefix(inWord.count-1))"]
        }
        if inWord.contains(",") {
            return ["______,", "\(inWord.prefix(inWord.count-1))"]
        }
        if inWord.contains("’s") {
            return ["______’s", "\(inWord.prefix(inWord.count-2))"]
        }
        if inWord.contains(":") {
            return ["______:", "\(inWord.prefix(inWord.count-1))"]
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
    
}

