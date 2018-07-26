//
//  SecondFilterViewController.swift
//  Know The News
//
//  Created by Necanow on 7/26/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class SecondFilterViewController: UIViewController {

    var articles = [[String: String]]()
    var keyword = ""
    
    //=========================================
    // VIEW DID LOAD
    //=========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    @IBAction func onFinishedEditing(_ sender: UITextField) {
        if sender.text != nil {
            keyword = sender.text!
        }
    }
    
    @IBAction func onTappedBegin(_ sender: Any) {
        if keyword.count > 0 {
            setAndSearchQuery()
        } else {
            self.loadError(problem: "Please input a keyword.")
        }
    }
    
    //=========================================
    // Sends the VC the sourceType selected
    //=========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.title = self.keyword
        dvc.articles = self.articles
    }
    
    //--------------------//
    // QUERYING FUNCTIONS //
    //--------------------//
    
    func setAndSearchQuery() {
        var query = "https://newsapi.org/v1/everything?q=\(keyword)&apiKey=\(apiKey)"
        
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
