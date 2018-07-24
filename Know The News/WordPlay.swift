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
    
    override init() {
        super.init()
        // do nothing
    }
    
    func updateWord(to: String) {
        wordID = to.lowercased()
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
