//
//  SourceTypeViewController.swift
//  Know The News
//
//  Created by Necanow on 7/11/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

let apiKey = "bd76ccc886ef4d60bcb5443eebdd6cb4" // global API Key

class SourceTypeViewController: UIViewController {
    
    var sources = [[String: String]]()
    
    @IBOutlet weak var sourceBok: UIView!
    var passType = "general" // default
    @IBOutlet var typeViews: [UIImageView]!
    let names = ["general", "business", "technology", "entertainment", "science", "sports", "all"]
    
    var country = "us" // default
    @IBOutlet var countryButtons: [UIButton]!
    let countryCodes = ["au", "de", "us", "gb", "in", "it", "all"]
    
    
    //=========================================
    // VIEW DID LOAD
    //=========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    //=========================================
    // Handles when a news type is tapped
    //=========================================
    @IBAction func onTappedScreen(_ sender: UITapGestureRecognizer) {
        let loc = sender.location(in: sourceBok)
        
        for type in typeViews {
            if type.frame.contains(loc) {
                let selected = names[type.tag]
                
                if !(passType == selected) {
                    for t in typeViews { t.backgroundColor = .clear }
                    type.backgroundColor = .white
                    passType = selected
                }
                break
            }
        }
    }
    
    @IBAction func onTappedLanguage(_ sender: UIButton) {
        let selectedCode = countryCodes[sender.tag]
        
        if !(country == selectedCode) {
            for b in countryButtons { b.backgroundColor = .clear }
            sender.backgroundColor = .white
            country = selectedCode
        }
    }
    
    
    @IBAction func onTappedBegin(_ sender: Any) {
        //performSegue(withIdentifier: "gameSegue", sender: self)
        setAndSearchQuery()
    }
    
    //=========================================
    // Sends the VC the sourceType selected
    //=========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.title = self.passType
        dvc.sources = self.sources
    }
    
    //=========================================
    // Handles when user taps on the NewsAPI
    // attribution
    //=========================================
    @IBAction func openNewsAPI(_ sender: Any) {
        let url = URL(string: "https://newsapi.org/")
        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
    }
    
    //--------------------//
    // QUERYING FUNCTIONS //
    //--------------------//
    
    func setAndSearchQuery() {
        var query = "https://newsapi.org/v1/sources?language=en"
        query += (country == "all" ? "" : "&country=\(country)") //add country code, if applicable
        query += (passType == "all" ? "&apiKey=\(apiKey)" : "&category=\(passType)&apiKey=\(apiKey)") //add source type, if applicable
        print("querying: \(query)")
        
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
    
    //=========================================
    // Parses for all sources of a given type
    //=========================================
    func parse(json: JSON) {
        for result in json["sources"].arrayValue {
            let id = result["id"].stringValue
            let name = result["name"].stringValue
            let description = result["description"].stringValue
            
            let source = ["id": id, "name": name, "description": description]
            sources.append(source)
        }
        nowSegue() // segue after all the sources have been appended
        
//        DispatchQueue.main.async {
//            [unowned self] in
//            //self.chooseRandomArticle()
//            self.performSegue(withIdentifier: "gameSegue", sender: self)
//        }
    }
    func nowSegue() {
        DispatchQueue.main.async {
            [unowned self] in
            self.performSegue(withIdentifier: "gameSegue", sender: self)
        }
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
    
}
