//
//  BeginViewController.swift
//  Know The News
//
//  Created by Necanow on 7/13/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class BeginViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomOut()
    }
    
    func zoomOut() {
        UIView.animate(withDuration: 1.0, animations: {
            self.imageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }) { (void) in
            self.zoomToSize()
        }
    }
    
    func zoomToSize() {
        UIView.animate(withDuration: 2.0) {
            self.imageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
}
