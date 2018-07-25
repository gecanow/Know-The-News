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
    var passType = "all" // default
    @IBOutlet var typeViews: [UIImageView]!
    let names = ["general", "business", "technology", "entertainment", "science", "sports", "health", "all"]
    
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
                passType = names[type.tag]
                performSegue(withIdentifier: "gameSegue", sender: self)
                break
            }
        }
    }
    
    //=========================================
    // Sends the VC the sourceType selected
    //=========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.sourceType = passType
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
