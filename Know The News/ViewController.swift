//
//  ViewController.swift
//  Know The News
//
//  Created by Necanow on 7/9/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var missingWord : String?
    
    var sources = [[String: String]]()
    let apiKey = "5d892509a49046a087917c466fa80d09"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        chooseRandomArticle()
    }
    
    func chooseRandomArticle() {
        let index = Int(arc4random_uniform(UInt32(sources.count - 1)))
        let chosenSource = Source(theSource: sources[index], theApiKey: apiKey)
        let myArticle = chosenSource.retrieveRandomArticle()
        
        
        headlineLabel.text = gamePlayTitle(myArticle["title"]!)
        sourceLabel.text = "\(chosenSource.source["name"]!) reports:"
        descriptionLabel.text = myArticle["description"]
        
        let myWord = WordPlay(word: missingWord!)
        print("The missing word is: \(myWord.wordID)")
    }
    
    func gamePlayTitle(_ fromName: String) -> String {
        let arr = fromName.split(separator: " ")
        
        var longest = 0
        for wordI in 1..<arr.count {
            if arr[wordI].count > arr[longest].count && !arr[wordI].contains("-") && !arr[wordI].contains("\'") {
                longest = wordI
            }
        }
        missingWord = String(arr[longest])
        if (missingWord?.contains("."))! {
            missingWord?.remove(at: (missingWord?.index(of: "."))!)
        }
        
        var outputString = ""
        for wordI in 0..<arr.count {
            if wordI == longest {
                outputString += "_____ "
            } else {
                outputString += arr[wordI] + " "
            }
        }
        return outputString
    }
}

