//
//  Chip.swift
//  Know The News
//
//  Created by Necanow on 7/23/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class Chip: UILabel {
    
    var home : CGPoint!
    var atHome = true
    
    convenience init(atPoint: CGPoint, ofSize: CGSize, str: String) {
        self.init(frame: CGRect(origin: atPoint, size: ofSize))
        home = atPoint
        
        self.text = str
        self.textColor = .black
        self.textAlignment = .center
        
        numberOfLines = 1
        minimumScaleFactor = 0.1
        adjustsFontSizeToFitWidth = true
        
        layer.cornerRadius = 2
        layer.borderWidth = 1
    }
}
