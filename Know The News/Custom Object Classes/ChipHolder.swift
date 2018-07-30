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
    
    //=========================================
    // INIT - atPoint, ofSize, atIndex index
    //=========================================
    convenience init(atPoint: CGPoint, ofSize: CGSize, index: Int) {
        self.init(frame: CGRect(origin: atPoint, size: ofSize))
        self.index = index
        self.backgroundColor = .white
        
        self.text = " "
        self.textColor = .black
        self.textAlignment = .center
        self.clipsToBounds = true
        
        layer.cornerRadius = 4
        layer.borderWidth = 1
    }
    
    //=========================================
    // Insert a chip into the holder
    //=========================================
    func setIn(chip: Chip) {
        if myChip != nil {
            removeChip() // fail-safe
        }
        myChip = chip
        myChip?.delegate = self
        myChip?.frame.origin = self.frame.origin
    }
    
    //=========================================
    // Remove the chip I'm currently holding
    //=========================================
    func removeChip() {
        if myChip != nil {
            myChip!.frame.origin = myChip!.home // can animate later?
            myChip!.delegate = nil
            myChip = nil
        }
    }
    
    //=========================================
    // Returns my index
    //=========================================
    func getIndex() -> Int {
        return index
    }
}
