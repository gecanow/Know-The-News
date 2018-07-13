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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.sourceType = passType
    }
    
}
