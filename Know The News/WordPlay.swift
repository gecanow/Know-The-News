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
    
    let defaults = UserDefaults.standard
    
    override init() {
        super.init()
        // do nothing
    }
    
    func updateWord(to: String) {
        wordID = to.lowercased()
        
//        let inflectionQuery = "https://od-api.oxforddictionaries.com:443/api/v1/inflections/\(language)/\(wordID!)"
//        let thesaurusQuery = "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(wordID!)/synonyms;antonyms"
//        if let url = URL(string: inflectionQuery) {
//            var request = URLRequest(url: url)
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.addValue(appId, forHTTPHeaderField: "app_id")
//            request.addValue(appKey, forHTTPHeaderField: "app_key")
//
//            let session = URLSession.shared
//            _ = session.dataTask(with: request, completionHandler: { data, response, error in
//                if let _ = response,
//                    let data = data,
//                    let jsonData = try? JSON(data: data) {
//                    //print(jsonData)
//                    self.parseInflection(json: jsonData)
//                    return
//                } else {
//                    self.loadError()
//                }
//            }).resume()
//        }
    }
    
    func randomizedCharacterList() -> [Character] {
        var mustHaveChars = [Character]()
        
        for char in 0..<wordID.count {
            let index = wordID.index(wordID.startIndex, offsetBy: char)
            let myChar = wordID[index]
            
            let randomIndex = arc4random_uniform(UInt32(mustHaveChars.count))
            mustHaveChars.insert(myChar, at: Int(randomIndex))
        }
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        for _ in 0..<(20-wordID.count) {
            let randomChar = arc4random_uniform(26)
            let index = alphabet.index(alphabet.startIndex, offsetBy: randomChar)
            let myChar = alphabet[index]
            
            let randomIndex = arc4random_uniform(UInt32(mustHaveChars.count))
            mustHaveChars.insert(myChar, at: Int(randomIndex))
        }
        return mustHaveChars
    }
    
    func analyze(word: [String]) -> [Int] {
        var output = [Int]()
        
        for i in 0..<word.count {
            let indexReal = wordID.index(wordID.startIndex, offsetBy: i)
            
            if word[i] == String(wordID[indexReal]) {
                output += [1]
            } else if word[i] == " " {
                output += [-1]
            } else {
                output += [0]
            }
        }
        return output
    }
}
