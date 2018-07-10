//
//  WordPlay.swift
//  Know The News
//
//  Created by Necanow on 7/9/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class WordPlay: NSObject {
    
    var wordID : String!
    
    let appId = "2a87bd3b"
    let appKey = "e2b929b0f6976ff5e0084a1503530f2a"
    let language = "en"
    
    convenience init(word: String) {
        self.init()
        wordID = word.lowercased()
        
        let query = "https://od-api.oxforddictionaries.com:443/api/v1/inflections/\(language)/\(wordID!)"
        if let url = URL(string: query) {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(appId, forHTTPHeaderField: "app_id")
            request.addValue(appKey, forHTTPHeaderField: "app_key")
            
            let session = URLSession.shared
            _ = session.dataTask(with: request, completionHandler: { data, response, error in
                if let response = response,
                    let data = data,
                    let jsonData = try? JSON(data: data) {
                    self.parse(json: jsonData)
                    return
                } else {
                    self.loadError()
                }
            }).resume()
        }
    }
    
    func parse(json: JSON) {
        let result = json["results"][0]
        let entries = result["lexicalEntries"][0]
        let partOfSpeech = entries["lexicalCategory"]
        
        print("\(wordID!) is a \(partOfSpeech)")
    }
    
    func loadError() {
        DispatchQueue.main.async {
            [weak self] in
            print("Word Play: error loading")
        }
    }
    
}
