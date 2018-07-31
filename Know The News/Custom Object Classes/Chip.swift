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
    var delegate : ChipDelegate?
    
    //=========================================
    // INIT - atPoint, ofSize, str
    //=========================================
    convenience init(atPoint: CGPoint, ofSize: CGSize, str: String) {
        self.init(frame: CGRect(origin: atPoint, size: ofSize))
        home = atPoint
        
        self.text = str
        self.font = UIFont.boldSystemFont(ofSize: 22)
        self.textColor = .black
        self.textAlignment = .center
        
        numberOfLines = 1
        minimumScaleFactor = 0.1
        adjustsFontSizeToFitWidth = true
        
        layer.cornerRadius = 4
        layer.borderWidth = 1
    }
    
    //============================================
    // If the chip is in a holder and therefore
    // has a delegate, return the holder's index.
    // Otherwise, return -1
    //============================================
    func holderIndex() -> Int {
        if delegate == nil {
            return -1
        }
        return delegate!.getIndex()
    }
}
