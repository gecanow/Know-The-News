//
//  WordPlay.swift
//  Know The News
//
//  Created by Necanow on 7/9/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

var politicalWords = [String: [String]]() //global

protocol WordPlayDelegate {
    func loadUpOptions(selection: [String])
}

class WordPlay: NSObject {
    
    var delegate : WordPlayDelegate?
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
        
        if let savedData = defaults.object(forKey: "politcalWordsArray") as? Data {
            if let decoded = try? JSONDecoder().decode([String: [String]].self, from: savedData) {
                politicalWords = decoded
            }
        }
        
        let query = "https://od-api.oxforddictionaries.com:443/api/v1/inflections/\(language)/\(wordID!)"
        //let query = "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(wordID!)"
        //let query = "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(wordID!)/synonyms;antonyms"
        if let url = URL(string: query) {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue(appId, forHTTPHeaderField: "app_id")
            request.addValue(appKey, forHTTPHeaderField: "app_key")
            
            let session = URLSession.shared
            _ = session.dataTask(with: request, completionHandler: { data, response, error in
                if let _ = response,
                    let data = data,
                    let jsonData = try? JSON(data: data) {
                    //print(jsonData)
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
        let partOfSpeech = "\(entries["lexicalCategory"])"
        
        let _ = entries["entries"][0]["grammaticalFeatures"] //grammatical features
        
        print("\(wordID!) is a \(partOfSpeech)")
        
        if politicalWords[partOfSpeech] == nil {
            loadWordListWithSame(speechType: partOfSpeech)
        } else {
            retrieveAndSendFrom(list: politicalWords[partOfSpeech]!, num: 3)
        }
    }
    
    func loadError() {
        DispatchQueue.main.async {
            print("Word Play: error loading")
            print("assuming it's a noun...")
            
            if politicalWords["Noun"] == nil {
                self.loadWordListWithSame(speechType: "Noun")
            } else {
                self.retrieveAndSendFrom(list: politicalWords["Noun"]!, num: 3)
            }
        }
    }
    
    func loadWordListWithSame(speechType: String) {
        let filters = "lexicalCategory=\(speechType);domains=Politics"
        
        let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/wordlist/\(language)/\(filters)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let _ = response,
                let data = data,
                let jsonData = try? JSON(data: data) {
                self.extractWordData(json: jsonData, ofType: speechType)
                return
            } else {
                self.loadError()
            }
        }).resume()
    }
    
    func extractWordData(json: JSON, ofType: String) {
        for information in json["results"] {
            let word = "\(information.1["word"])"
            
            if politicalWords[ofType] == nil {
                politicalWords[ofType] = [word]
            } else {
                politicalWords[ofType]!.append(word)
            }
        }
        saveData()
        retrieveAndSendFrom(list: politicalWords[ofType]!, num: 3)
    }
    
    func retrieveAndSendFrom(list: [String], num: Int) {
        let output = randomList(from: list, amount: num) + [wordID]
        delegate?.loadUpOptions(selection: output)
    }
    
    func randomList(from: [String], amount: Int) -> [String] {
        var output = [String]()
        var wordChoice = ""
        
        for _ in 0..<amount {
            repeat {
                wordChoice = from[Int(arc4random_uniform(UInt32(from.count-1)))]
            } while output.contains(wordChoice)
            output.append(wordChoice)
        }
        return output
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(politicalWords) {
            defaults.set(encoded, forKey: "politcalWordsArray")
        }
    }
}
