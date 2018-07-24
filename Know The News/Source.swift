//
//  Source.swift
//  Know The News
//
//  Created by Necanow on 7/9/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class Source: NSObject {
    
    var articles = [[String: String]]()
    var apiKey = ""
    var source = [String: String]()
    
    //=========================================
    // INIT - the source, the ApiKey
    //=========================================
    convenience init(theSource: [String: String], theApiKey: String) {
        self.init()
        self.source = theSource
        self.apiKey = theApiKey
        
        let query = "https://newsapi.org/v1/articles?" + "source=\(source["id"]!)&apiKey=\(apiKey)"
        
        if let url = URL(string: query) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                if json["status"] == "ok" {
                    self.parse(json: json)
                    return
                }
            }
            self.loadError()
        }
    }
    
    //=========================================
    // Parses for all articles from source
    //=========================================
    func parse(json: JSON) {
        for result in json["articles"].arrayValue {
            let title = result["title"].stringValue
            let description = result["description"].stringValue
            let url = result["url"].stringValue
            let article = ["title": title, "description": description, "url": url]
            articles.append(article)
        }
    }
    
    //=========================================
    // Alerts of an error
    //=========================================
    func loadError() {
        DispatchQueue.main.async {
            print("Source: error loading")
        }
    }
    
    //===========================================
    // Returns a random article from this source
    //===========================================
    func retrieveRandomArticle() -> [String: String] {
        let randomIndex = Int(arc4random_uniform(UInt32(self.articles.count)))
        return articles[randomIndex]
    }
}
