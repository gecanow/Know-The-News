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
    
    func parse(json: JSON) {
        for result in json["articles"].arrayValue {
            let title = result["title"].stringValue
            let description = result["description"].stringValue
            let url = result["url"].stringValue
            let article = ["title": title, "description": description, "url": url]
            articles.append(article)
        }
    }
    
    func loadError() {
        DispatchQueue.main.async {
            print("Source: error loading")
        }
    }
    
    func retrieveRandomArticle() -> [String: String] {
        let randomIndex = Int(arc4random_uniform(UInt32(self.articles.count - 1)))
        return articles[randomIndex]
    }
}
