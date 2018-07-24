//
//  ChipHolder.swift
//  Know The News
//
//  Created by Necanow on 7/23/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

protocol ChipDelegate {
    func getIndex() -> Int
}

class ChipHolder: UILabel, ChipDelegate {

    var myChip : Chip?
    var index = -1
    
    convenience init(atPoint: CGPoint, ofSize: CGSize, index: Int) {
        self.init(frame: CGRect(origin: atPoint, size: ofSize))
        self.index = index
        
        self.text = " "
        self.textColor = .black
        self.textAlignment = .center
        
        layer.cornerRadius = 2
        layer.borderWidth = 1
    }
    
    func setIn(chip: Chip) {
        if myChip != nil {
            removeChip() // fail-safe
        }
        myChip = chip
        myChip?.delegate = self
        myChip?.frame.origin = self.frame.origin
    }
    
    func removeChip() {
        if myChip != nil {
            myChip!.frame.origin = myChip!.home // can animate later?
            myChip!.delegate = nil
            myChip = nil
        }
    }
    
    func getIndex() -> Int {
        return index
    }
}
