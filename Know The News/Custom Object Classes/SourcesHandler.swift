//
//  SourcesHandler.swift
//  Know The News
//
//  Created by Necanow on 7/29/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class SourcesHandler: NSObject {
    
    var articles = [[String: String]]()
    
    //=========================================
    // INIT - the source, the ApiKey
    //=========================================
    convenience init(theSources: [[String: String]], theApiKey: String, lang: String) {
        self.init()
        
        var mySplitSources = [[[String: String]]]()
        mySplitSources.append([[String: String]]())
        
        var indexCtr = 0
        
        for source in theSources {
            if mySplitSources[indexCtr].count >= 20 {
                indexCtr += 1
                mySplitSources.append([[String: String]]())
            }
            mySplitSources[indexCtr].append(source)
        }
        
        for sourceArr in mySplitSources {
            var query = "https://newsapi.org/v2/everything?sources="
            for id in sourceArr {
                query += id["id"]! + ","
            }
            
            let langKey = lang.count > 0 ? "&language=\(lang)" : ""
            query = query.prefix(query.count-1) + langKey + "&apiKey=\(theApiKey)"
            print("performing: \(query)")
            
            performQuery(query)
        }
    }
    
    func performQuery(_ query: String) {
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
    
    //=========================================
    // Parses for all articles from each source
    //=========================================
    func parse(json: JSON) {
        for result in json["articles"].arrayValue {
            let title = result["title"].stringValue
            let description = result["description"].stringValue
            let url = result["url"].stringValue
            let date = String(result["publishedAt"].stringValue.prefix(10))
            let sourceName = result["source"]["name"].stringValue // check for accuracy
            
            let article = ["title": title, "description": description, "url": url, "sourceName": sourceName, "date": date, "timeToComplete": "", "isFinished": "false"]
            
            // article = ["title": title, "description": description, "url": url, "sourceName": sourceName, "date": date, "timeToComplete": ""]
            articles.append(article)
        }
        print("finished loading all articles")
    }
    
    //=========================================
    // Alerts of an error
    //=========================================
    func loadError(problem: String) {
        DispatchQueue.main.async {
            print(problem)
            print("Source: error loading")
        }
    }
}
