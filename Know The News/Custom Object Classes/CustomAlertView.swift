//
//  CustomAlertView.swift
//  Know The News
//
//  Created by Necanow on 7/29/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

protocol CustomAlertProtocol {
    func saveButtonAction()
    func nextButtonAction()
    func hideCustomAlert()
}

class CustomAlertView: UIView {
    
    let appColor = #colorLiteral(red: 0.6112467448, green: 0.7109888812, blue: 0.9402669271, alpha: 1) //clueLabel.backgroundColor
    var customAlertLabel = UILabel()
    var savedAlert = UIView()
    var delegate : CustomAlertProtocol?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func createCustomAlert(_ onView: UIView) {
        // 1 - retreive full screen stats
        let screenW = UIScreen.main.bounds.width//self.view.frame.width
        let screenH = UIScreen.main.bounds.height//self.view.frame.height
        
        // 2 - create the alert view
        let alertW = CGFloat(275)
        let alertH = CGFloat(400)
        
        let xCor = (screenW - alertW) / 2.0
        let yCor = (screenH - alertH) / 2.0
        
        self.frame = CGRect(x: xCor, y: yCor, width: alertW, height: alertH)
        self.backgroundColor = .white
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        
        // 3 - create the description label
        customAlertLabel = UILabel(frame: CGRect(x: 8, y: 0, width: alertW-16, height: 140.0))
        customAlertLabel.text = ""
        customAlertLabel.textAlignment = .center
        customAlertLabel.font = UIFont(name: "AvenirNext-Bold", size: 20.0)
        customAlertLabel.numberOfLines = 0
        customAlertLabel.lineBreakMode = .byWordWrapping
        
        
        var labelFrame = customAlertLabel.frame
        customAlertLabel.sizeToFit()
        
        var customHeight = customAlertLabel.frame.height
        if customHeight < 204 { customHeight = 204 }
        labelFrame.size.height = customHeight
        labelFrame.size.width = alertW-16 // must stay the same
        customAlertLabel.frame = labelFrame
        
        // 4 - create the message label
        let messageLabel = UILabel(frame: CGRect(x: 8, y: customHeight, width: alertW-16, height: 284.0-customHeight))
        messageLabel.text = "If you would like to save this article to your library, select 'Save and Continue'"
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "AvenirNext", size: 16.0)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        
        // 5 - create the Save and Continue button
        //let saveButton = UIButton(frame: CGRect(x: 0, y: 284.0, width: alertW, height: 40.0))
        let saveButton = GradientButton(frame: CGRect(x: 0, y: 284.0, width: alertW, height: 40.0))
        saveButton.startColor = appColor
        saveButton.endColor = .white
        saveButton.isVerticle = false
        
        saveButton.setTitle("Save and Continue", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18.0)
        saveButton.layer.borderWidth = 2
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        
        // 6 - create the continue button
        let nextButton = GradientButton(frame: CGRect(x: 0, y: 322.0, width: alertW, height: 40.0))
        nextButton.startColor = appColor
        nextButton.endColor = .white
        nextButton.isVerticle = false
        
        nextButton.setTitle("Continue to Next Article", for: .normal)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "AvenirNext", size: 18.0)
        nextButton.layer.borderWidth = 2
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        
        // 7 - create the cancel button
        let cancelButton = GradientButton(frame: CGRect(x: 0, y: 360.0, width: alertW, height: 40.0))
        cancelButton.startColor = appColor
        cancelButton.endColor = .white
        cancelButton.isVerticle = false
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "AvenirNext", size: 18.0)
        cancelButton.backgroundColor = .clear
        cancelButton.addTarget(self, action: #selector(hideCustomAlert), for: .touchUpInside)
        
        // 8 - add buttons and labels to the view
        self.addSubview(customAlertLabel)
        self.addSubview(messageLabel)
        self.addSubview(saveButton)
        self.addSubview(cancelButton)
        self.addSubview(nextButton)
        
        // 9 - add myAlert to the full view
        let blur = UIView(frame: CGRect(x: -xCor, y: -yCor, width: screenW, height: screenH))
        blur.backgroundColor = .white
        blur.alpha = 0.7
        self.addSubview(blur)
        self.sendSubview(toBack: blur)
        
        self.isHidden = true
        onView.addSubview(self)
    }
    @objc func saveButtonAction() {
        delegate?.saveButtonAction()
    }
    @objc func nextButtonAction() {
        delegate?.nextButtonAction()
    }
    @objc func hideCustomAlert() {
        delegate?.hideCustomAlert()
    }
    
    func createAndDisplaySavedAlert(_ toView: UIView) {
        // 1 - retreive full screen stats
        let screenW = UIScreen.main.bounds.width//self.view.frame.width
        let screenH = UIScreen.main.bounds.height//self.view.frame.height
        
        // 2 - create the alert view
        let alertW = CGFloat(150)
        let alertH = CGFloat(150)
        
        let xCor = (screenW - alertW) / 2.0
        let yCor = (screenH - alertH) / 2.0
        
        savedAlert = UIView(frame: CGRect(x: xCor, y: yCor, width: alertW, height: alertH))
        savedAlert.backgroundColor = .white
        savedAlert.layer.borderWidth = 2
        savedAlert.layer.cornerRadius = 5
        
        // 3 - create the description label
        let lab = UILabel(frame: CGRect(x: 8, y: 0, width: alertW-16, height: 40.0))
        lab.text = "Saved"
        lab.textAlignment = .center
        lab.font = UIFont(name: "AvenirNext-Bold", size: 25.0)
        
        // 4 - draw a saved icon
        let savedIcon = SavedIconDrawView(frame: CGRect(x: 8, y: 40, width: alertW-16, height: 100.0))
        savedIcon.backgroundColor = .clear
        savedIcon.drawColor = appColor
        
        // 9 - add myAlert to the full view
        let blur = UIView(frame: CGRect(x: -xCor, y: -yCor, width: screenW, height: screenH))
        blur.backgroundColor = .white
        blur.alpha = 0.7
        savedAlert.addSubview(blur)
        savedAlert.sendSubview(toBack: blur)
        
        savedAlert.addSubview(lab)
        savedAlert.addSubview(savedIcon)
        
        toView.addSubview(savedAlert)
        savedIcon.setNeedsDisplay()
        
        let _ = Timer.scheduledTimer(withTimeInterval: savedIcon.drawTime + 0.5, repeats: false) { (timer) in
            self.savedAlert.removeFromSuperview()
            self.delegate?.nextButtonAction()
        }
    }
}
