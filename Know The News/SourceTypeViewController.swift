//
//  SourceTypeViewController.swift
//  Know The News
//
//  Created by Necanow on 7/11/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class SourceTypeViewController: UIViewController {
    
    @IBOutlet weak var sourceBok: UIView!
    var passType = "general" // default
    @IBOutlet var typeViews: [UIImageView]!
    let names = ["general", "business", "technology", "entertainment", "science", "sports", "all"]
    
    var language = "en" // default
    @IBOutlet var languageButtons: [UIButton]!
    let languageCodes = ["ar", "de", "en", "es", "fr", "he", "it", "nl", "no", "pt", "ru", "se", "zh"]
    
    
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
        let selectedCode = languageCodes[sender.tag]
        
        if !(language == selectedCode) {
            for b in languageButtons { b.backgroundColor = .clear }
            sender.backgroundColor = .white
            language = selectedCode
        }
    }
    
    
    @IBAction func onTappedBegin(_ sender: Any) {
        performSegue(withIdentifier: "gameSegue", sender: self)
    }
    
    //=========================================
    // Sends the VC the sourceType selected
    //=========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.sourceType = passType
        dvc.language = language
    }
    
    //=========================================
    // Handles when user taps on the NewsAPI
    // attribution
    //=========================================
    @IBAction func openNewsAPI(_ sender: Any) {
        let url = URL(string: "https://newsapi.org/")
        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
    }
    
    
}
