//
//  FilterTypeViewController.swift
//  Know The News
//
//  Created by Necanow on 7/26/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class FilterTypeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.adjustsFontSizeToFitWidth = true
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
