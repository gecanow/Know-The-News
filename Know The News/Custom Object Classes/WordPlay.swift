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
    var article : [String: String]!
    
    //=========================================
    // INIT
    //=========================================
    override init() {
        super.init()
        // do nothing
    }
    
    //=========================================
    // Updates the wordplay word
    //=========================================
    func updateWord(to: String, fromArticle: [String: String]) {
        wordID = to.lowercased()
        article = fromArticle
    }
    
    //==============================================
    // Returns an array of *length* characters in a
    // random order, containing all the characters
    // in the wordID plus extra random characters
    //==============================================
    func randomizedCharacterList(length: Int) -> [Character] {
        var mustHaveChars = [Character]()
        
        for char in 0..<wordID.count {
            let index = wordID.index(wordID.startIndex, offsetBy: char)
            let myChar = wordID[index]
            
            let randomIndex = arc4random_uniform(UInt32(mustHaveChars.count))
            mustHaveChars.insert(myChar, at: Int(randomIndex))
        }
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        for _ in 0..<(length-wordID.count) {
            let randomChar = arc4random_uniform(26)
            let index = alphabet.index(alphabet.startIndex, offsetBy: randomChar)
            let myChar = alphabet[index]
            
            let randomIndex = arc4random_uniform(UInt32(mustHaveChars.count))
            mustHaveChars.insert(myChar, at: Int(randomIndex))
        }
        return mustHaveChars
    }
    
    //=========================================
    // Analyzes a String array compared to the
    // wordID. At each placement...
    //  1 - correct character
    //  0 - wrong character
    // -1 - no character
    //=========================================
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
