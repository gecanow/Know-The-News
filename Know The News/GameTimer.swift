//
//  GameTimer.swift
//  Know The News
//
//  Created by Necanow on 7/24/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class GameTimer: UILabel {
    
    var ms = 0
    var sec = 0
    var min = 0
    
    var myTimer : Timer?
    
    func start() {
        stop() // fail-safe
        
        myTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            if self.ms == 59 {
                if self.sec == 59 {
                    self.min += 1
                    self.sec = 0
                } else {
                    self.sec += 1
                }
                self.ms = 0
            } else {
                self.ms += 1
            }
            
            self.setText()
        }
    }
    
    func stop() {
        if myTimer != nil { myTimer!.invalidate() }
    }
    
    func reset() {
        stop() // fail-safe
        
        ms = 0
        sec = 0
        min = 0
        setText()
    }
    
    func setText() {
        self.text = "\(format(num: min)):\(format(num: sec)).\(format(num: ms))"
    }
    
    func format(num: Int) -> String {
        return num < 10 ? "0\(num)" : "\(num)"
    }
}
