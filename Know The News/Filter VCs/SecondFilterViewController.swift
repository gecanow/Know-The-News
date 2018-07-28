//
//  SecondFilterViewController.swift
//  Know The News
//
//  Created by Necanow on 7/26/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class SecondFilterViewController: UIViewController, UITextFieldDelegate {

    var articles = [[String: String]]()
    var keywords = [String]()
    var keywordLabels = [UILabel]()
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var keywordsView: UIView!
    
    var xCor = 0
    var yCor = 8
    
    //=========================================
    // VIEW DID LOAD
    //=========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
        textField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
        let loc = touches.first?.location(in: keywordsView)
        for x in 0..<keywordLabels.count {
            let label = keywordLabels[x]
            if label.frame.contains(loc!) {
                let word = String(label.text!.prefix(label.text!.count-2)) // removes the " ⊖"
                keywords.remove(at: keywords.index(of: word)!)
                keywordLabels.remove(at: x)
                
                if keywordLabels.count > 0 && x < keywordLabels.count {
                    shiftKeywords(after: x, atX: label.frame.minX, atY: label.frame.minY)
                }
                label.removeFromSuperview()
                break
            }
        }
        if keywordLabels.count == 0 {
            xCor = 0
            yCor = 8
        } else {
            let finalLabel = keywordLabels[keywordLabels.count-1]
            xCor = Int(finalLabel.frame.maxX+8)
            yCor = Int(finalLabel.frame.minY)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        onTappedAdd(self)
        return true
    }
    
    @IBAction func onTappedAdd(_ sender: Any) {
        if let kw = textField.text?.lowercased() {
            if kw.count > 0 && !keywords.contains(kw) {
                addKeyWord(kw)
            }
        }
        textField.text = ""
    }
    
    func addKeyWord(_ word: String) {
        // first create the label
        let wordLabel = UILabel(frame: CGRect(x: xCor, y: yCor, width: 70, height: 30))
        wordLabel.text = word + " ⊖"
        wordLabel.font = UIFont(name: "Sofija", size: CGFloat(25))
        wordLabel.sizeToFit() // check for resized height?
        
        let myWidth = wordLabel.frame.width + 16
        let myHeight = wordLabel.frame.height + 16
        updateCoordinates(w: wordLabel.frame.width, h: wordLabel.frame.height)
        wordLabel.frame = CGRect(x: CGFloat(xCor), y: CGFloat(yCor), width: myWidth, height: myHeight)
        
        wordLabel.textAlignment = .center
        wordLabel.backgroundColor = .white
        wordLabel.clipsToBounds = true
        wordLabel.layer.cornerRadius = 5
        
        keywordsView.addSubview(wordLabel)
        keywordLabels.append(wordLabel)
        keywords.append(word)
        
        xCor += Int(myWidth+8) // update xCor for the next recipient
    }
    
    func shiftKeywords(after: Int, atX: CGFloat, atY: CGFloat) {
        var leftX = atX
        var leftY = atY
        
        var myLab : UILabel!
        for i in after..<keywordLabels.count {
            myLab = keywordLabels[i]
            if (leftX + myLab.frame.width + 8) < keywordsView.frame.width {
                myLab.frame = CGRect(x: leftX, y: leftY, width: myLab.frame.width, height: myLab.frame.height)
            } else if leftY < myLab.frame.minY {
                myLab.frame = CGRect(x: 0, y: myLab.frame.minY, width: myLab.frame.width, height: myLab.frame.height)
            } else { }
            leftX = myLab.frame.maxX + 8
            leftY = myLab.frame.minY
        }
        updateCoordinates(w: myLab.frame.width, h: myLab.frame.height)
    }
    
    func updateCoordinates(w: CGFloat, h: CGFloat) {
        let myWidth = w + 16
        let myHeight = h + 16
        if CGFloat(xCor) + myWidth+8 > keywordsView.frame.width {
            xCor = 0
            yCor += Int(myHeight) + 8
        }
    }
    
    @IBAction func onTappedBegin(_ sender: Any) {
        articles = [[String: String]]()
        if keywords.count > 0 {
            setAndSearchQuery()
        } else {
            self.loadError(problem: "Please input at least one keyword.")
        }
    }
    
    //=========================================
    // Sends the VC the sourceType selected
    //=========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.title = "Keywords"
        dvc.articles = self.articles
    }
    
    //--------------------//
    // QUERYING FUNCTIONS //
    //--------------------//
    
    func setAndSearchQuery() {
        var queryKeys = ""
        for key in keywords {
            queryKeys += key + " AND " //+ "%20OR%20"
        }
        queryKeys = String(queryKeys.prefix(queryKeys.count-5))//8))
        var query = "https://newsapi.org/v2/everything?q=\(queryKeys)&apiKey=\(apiKey)"
        query = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(query)
        
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
            self.loadError(problem: "There was a problem loading the news feed.")
        }
    }
    
    //=========================================
    // Parses for all sources of a given type
    //=========================================
    func parse(json: JSON) {
        print(json["totalResults"])
        for result in json["articles"].arrayValue {
            let title = result["title"].stringValue
            let description = result["description"].stringValue
            let url = result["url"].stringValue
            let date = String(result["publishedAt"].stringValue.prefix(10))
            let sourceName = result["source"]["name"].stringValue
            
            let article = ["title": title, "description": description, "url": url, "sourceName": sourceName, "date": date]
            articles.append(article)
        }
        
        if articles.count > 0 {
            DispatchQueue.main.async {
                [unowned self] in
                self.performSegue(withIdentifier: "gameSegue2", sender: self)
            }
        } else {
            loadError(problem: "Not enough sources available.")
        }
    }
    
    //=========================================
    // Informs the user of a loading error
    //=========================================
    func loadError(problem: String) {
        DispatchQueue.main.async {
            [unowned self] in
            //(rest of method goes here)
            
            let alert = UIAlertController(title: "Loading Error",
                                          message: problem,
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
