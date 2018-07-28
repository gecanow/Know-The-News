//
//  SavedIconDrawView.swift
//  Know The News
//
//  Created by Necanow on 7/27/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class SavedIconDrawView: UIView {
    
    var drawTime = 1.0
    var drawColor : UIColor = .black
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let w = self.frame.width
        let h = self.frame.height
        let xmid = (w/2.0) - (w/9.0)
        
        // path a check mark
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xmid - (w/5.0), y: (h/2.0) + 4))
        path.addLine(to: CGPoint(x: xmid, y: h - 16))
        path.addLine(to: CGPoint(x: xmid + (w/3.0), y: 16))
        
        // set the width and color
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = drawColor.cgColor
        
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineCapRound
        
        shapeLayer.lineWidth = 6
        shapeLayer.path = path.cgPath
        self.backgroundColor = .clear
        
        // animate
        layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = drawTime
        shapeLayer.add(animation, forKey: "MyAnimation")
    }
}
