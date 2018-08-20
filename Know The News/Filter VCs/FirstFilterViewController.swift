//
//  SourceTypeViewController.swift
//  Know The News
//
//  Created by Necanow on 7/11/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

let apiKey = "bd76ccc886ef4d60bcb5443eebdd6cb4" // global API Key registered with newscluesapi@gmail.com

class FirstFilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var articles = [[String: String]]()
    
    @IBOutlet weak var sourceBok: UIView!
    var passType = "general" // default
    let names = ["general", "business", "technology", "entertainment", "science", "sports", "all"]
    
    var country = "us" // default
    let countryCodes = ["all", "au", "de", "us", "gb", "in", "it"]
    
    @IBOutlet weak var regionPickerView: UIPickerView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    //=========================================
    // VIEW DID LOAD
    //=========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
        
        regionPickerView.dataSource = self
        regionPickerView.delegate = self
        
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        
        regionPickerView.reloadAllComponents()
        regionPickerView.selectRow(3, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == regionPickerView {
            return countryCodes.count
        } else {
            return names.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 30, height: 60))
        var rowString = ""
        
        if pickerView == categoryPickerView {
            let myImageView = UIImageView(frame: CGRect(x: 15, y: 15, width: 30, height: 30))
            myImageView.contentMode = .scaleAspectFit
            myImageView.clipsToBounds = true
            
            switch row {
            case 2:
                rowString = "technology"
                myImageView.image = UIImage(named: "tech")
            default:
                rowString = names[row]
                myImageView.image = UIImage(named: rowString)
            }
            
            let myLabel = UILabel(frame: CGRect(x: 60, y: 0, width: pickerView.bounds.width - 90, height: 60))
            //myLabel.font = UIFont(name:some font, size: 18)
            myLabel.text = rowString
            
            myView.addSubview(myLabel)
            myView.addSubview(myImageView)
        } else {
            switch row {
            case 1: rowString = "Australia"
            case 2: rowString = "Germany"
            case 3: rowString = "USA"
            case 4: rowString = "UK"
            case 5: rowString = "India"
            case 6: rowString = "Italy"
            default: rowString = "All"
            }
            let myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 90, height: 60))
            //myLabel.font = UIFont(name:some font, size: 18)
            myLabel.text = rowString
            
            myView.addSubview(myLabel)
        }
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPickerView {
            passType = names[row]
        } else {
            country = countryCodes[row]
        }
    }
    
    @IBAction func onTappedBegin(_ sender: Any) {
        articles = [[String: String]]()
        setAndSearchQuery()
    }
    
    //=========================================
    // Sends the VC the sourceType selected
    //=========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.title = properTitle(forStr: passType)
        dvc.articles = self.articles
    }
    
    //=========================================
    // Returns a captialized, proper string
    //=========================================
    func properTitle(forStr: String) -> String {
        if forStr.count > 0 {
            let body = forStr.suffix(forStr.count-1).lowercased()
            let caps = forStr.prefix(1).uppercased()
            return caps + body
        }
        return forStr
    }
    
    //--------------------//
    // QUERYING FUNCTIONS //
    //--------------------//
    
    func setAndSearchQuery() {
        var query = "https://newsapi.org/v1/sources?language=en"
        query += (country == "all" ? "" : "&country=\(country)") //add country code, if applicable
        query += (passType == "all" ? "" : "&category=\(passType)") //add source type, if applicable
        query += "&apiKey=\(apiKey)"
        print("querying: \(query)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            [unowned self] in
            // rest of method goes here
            
            if let url = URL(string: query) {
                if let data = try? Data(contentsOf: url) {
                    let json = try! JSON(data: data)
                    if json["status"] == "ok" {
                        self.parse(json: json)
                        return
                    }
                }
            }
            self.loadError(problem: "There was a problem loading the news feed.")
        }
    }
    
    //=========================================
    // Parses for all sources of a given type
    //=========================================
    func parse(json: JSON) {
        var sources = [[String: String]]()
        for result in json["sources"].arrayValue {
            let id = result["id"].stringValue
            let name = result["name"].stringValue
            let description = result["description"].stringValue
            
            let source = ["id": id, "name": name, "description": description]
            sources.append(source)
        }
        
        let langCode = (country == "us" || country == "gb" || country == "au") ? "en" : ""
        let captialSource = SourcesHandler(theSources: sources, theApiKey: apiKey, lang: langCode)
        articles += captialSource.articles
        
        if articles.count > 0 {
            DispatchQueue.main.async {
                [unowned self] in
                self.performSegue(withIdentifier: "gameSegue", sender: self)
            }
        } else {
            loadError(problem: "Not enough sources available.")
        }
    }
    
    //=========================================
    // Informs the user of a loading error
    //=========================================
    func loadError(problem: String) {
        DispatchQueue.main.async {
            [unowned self] in
            //(rest of method goes here)
            
            let alert = UIAlertController(title: "Loading Error",
                                          message: problem,
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
