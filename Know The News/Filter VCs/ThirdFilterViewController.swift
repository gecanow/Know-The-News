//
//  ThirdFilterViewController.swift
//  Know The News
//
//  Created by Necanow on 7/26/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class ThirdFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var allSources = [[String: String]]()
    var searchedSources = [[String: String]]()
    var selectedSources = [[String: String]]()
    
    var articles = [[String: String]]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //=========================================
    // VIEW DID LOAD
    //=========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        let query = "https://newsapi.org/v2/sources?apiKey=\(apiKey)"
        DispatchQueue.global(qos: .userInitiated).async {
            [unowned self] in
            // rest of method goes here
            
            if let url = URL(string: query) {
                if let data = try? Data(contentsOf: url) {
                    let json = try! JSON(data: data)
                    if json["status"] == "ok" {
                        self.parseForSources(json: json)
                        return
                    }
                }
            }
            self.loadError(problem: "There was a problem loading the news feed.")
        }
    }
    
    //=========================================
    // Parses for all sources available
    // through NewsAPI
    //=========================================
    func parseForSources(json: JSON) {
        for result in json["sources"].arrayValue {
            let name = result["name"].stringValue
            let category = result["category"].stringValue
            let url = result["url"].stringValue
            let language = result["language"].stringValue
            let country = result["country"].stringValue
            let id = result["id"].stringValue
            
            let myIndex = "\(allSources.count)" // will be my index
            
            let source = ["name": name, "category": category, "url": url, "language": language, "country": country, "chosen": "no", "myIndex": myIndex, "id": id]
            allSources.append(source)
        }
        searchedSources = allSources
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //=========================================
    // Dismisses the keyboard is user taps
    // screen
    //=========================================
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //=========================================
    // Narrows down the searched sources
    // based on what the user types into the
    // search bar
    //=========================================
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 1 {
            var semiSearchedSources = [[String: String]]()
            for source in allSources {
                let allParts = source["name"]! + source["category"]! + fullLangName(code: source["language"]!) + fullCountryName(code: source["country"]!)
                if allParts.lowercased().contains(searchText.lowercased()) {
                    semiSearchedSources.append(source)
                }
            }
            searchedSources = semiSearchedSources
        } else {
            searchedSources = allSources
        }
        tableView.reloadData()
    }
    
    //=========================================
    // Dismisses the keyboard when the search
    // button is clicked
    //=========================================
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    //=========================================
    // TABLE VIEW DELEGATE FUNCTIONS
    // 1 - how many rows
    // 2 - cell display at each row
    // 3 - when a user taps on a cell
    //=========================================
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        let index = indexPath.row
        let allIndex = Int(searchedSources[index]["myIndex"]!)
        
        // UISwitch --
        let switchOn = allSources[allIndex!]["chosen"] == "no" ? false : true
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(switchOn, animated: true)
        switchView.tag = allIndex! // given the ACTUAL source index
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        //------------
        
        let title = searchedSources[index]["name"]
        
        let cat = fullCategoryName(code: searchedSources[index]["category"]!)
        let country = fullCountryName(code: searchedSources[index]["country"]!)
        let lang = fullLangName(code: searchedSources[index]["language"]!)
        let subtitle = "\(cat) News from \(country) (\(lang))"
        
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont(name: "CaslonOS-Regular", size: 16.0)
        cell.detailTextLabel?.text = subtitle
        cell.backgroundColor = .clear
        
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.detailTextLabel?.font = UIFont(name: "CaslonOS-Regular", size: 12.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("open url?")
        let url = URL(string: searchedSources[indexPath.row]["url"]!)
        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
    }
    
    //=========================================
    // Handles when a user taps on a switch
    //=========================================
    @objc func switchChanged(_ sender: UISwitch) {
        print(sender.tag)
        if sender.isOn {
            allSources[sender.tag]["chosen"] = "yes"
        } else {
            allSources[sender.tag]["chosen"] = "no"
        }
    }
    
    //=========================================
    // Handles when begin is tapped
    //=========================================
    @IBAction func onTappedBegin(_ sender: Any) {
        articles = [[String: String]]()
        
        for source in allSources {
            if source["chosen"] == "yes" {
                selectedSources.append(source)
            }
        }
        
        if selectedSources.count > 0 {
            setAndSearchQuery()
        } else {
            self.loadError(problem: "Please selected at least one source.")
        }
    }
    
    //=========================================
    // Return a capitalized category name
    //=========================================
    func fullCategoryName(code: String) -> String {
        return code.prefix(1).uppercased() + code.suffix(code.count-1)
    }
    
    //=========================================
    // Returns the full country name based on
    // it's two letter code
    //=========================================
    func fullCountryName(code: String) -> String {
        switch code {
        case "ar": return "Argentina"
        case "au": return "Australia"
        case "at": return "Austria"
        case "be": return "Belgium"
        case "br": return "Brazil"
        case "bg": return "Bulgaria"
        case "ca": return "Canada"
        case "cn": return "China"
        case "zh": return "China" // two options, 'zh' is not a real country code
        case "co": return "Colombia"
        case "cu": return "Cuba"
        case "cz": return "Czech Republic"
        case "eg": return "Egypt"
        case "fr": return "France"
        case "de": return "Germany"
        case "gr": return "Greece"
        case "hk": return "Hong Kong"
        case "hu": return "Hungary"
        case "in": return "India"
        case "id": return "Indonesia"
        case "ie": return "Ireland"
        case "il": return "Israel"
        case "is": return "Israel" // two options, 'is' usually iceland...
        case "it": return "Italy"
        case "jp": return "Japan"
        case "lv": return "Latvia"
        case "lt": return "Lithuania"
        case "my": return "Malaysia"
        case "mx": return "Mexico"
        case "ma": return "Morocco"
        case "nl": return "Netherlands"
        case "nz": return "New Zealand"
        case "ng": return "Nigeria"
        case "no": return "Norway"
        case "pk": return "Pakistan"
        case "ph": return "Philippines"
        case "pl": return "Poland"
        case "pt": return "Portugal"
        case "ro": return "Romania"
        case "ru": return "Russia"
        case "sa": return "Saudia Arabia"
        case "rs": return "Serbia"
        case "sg": return "Singapore"
        case "sk": return "Slovakia"
        case "si": return "Slovenia"
        case "za": return "South Africa"
        case "kr": return "South Korea"
        case "es": return "Spain"
        case "se": return "Sweden"
        case "ch": return "Switzerland"
        case "tw": return "Taiwan"
        case "th": return "Thailand"
        case "tr": return "Turkey"
        case "ae": return "UAE"
        case "ua": return "Ukraine"
        case "gb": return "United Kingdom"
        case "us": return "United States"
        case "ve": return "Venuzuela"
        default: return code
        }
    }
    
    //=========================================
    // Returns a full langugage name based on
    // its two letter code
    //=========================================
    func fullLangName(code: String) -> String {
        switch code {
        case "ar": return "Arabic | عربى"
        case "de": return "German | Deutsche"
        case "en": return "English"
        case "es": return "Spanish | Español"
        case "fr": return "French | le français"
        case "he": return "Hebrew | עִברִית"
        case "it": return "Italian | lo italiano"
        case "nl": return "Dutch | Nederlands"
        case "no": return "Norwegian | norsk"
        case "pt": return "Portuguese | o português"
        case "ru": return "Russian | русский"
        case "se": return "Sami" // or Northern Sami?
        case "zh": return "Chinese | 中文"
        default: return code // ud?
        }
    }
    
    //=========================================
    // Sends the VC the sourceType selected
    //=========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dvc = segue.destination as! ViewController
        dvc.title = "Self-Selected Sources"
        dvc.articles = self.articles
    }
    
    //--------------------//
    // QUERYING FUNCTIONS //
    //--------------------//
    
    func setAndSearchQuery() {
        let sourceHandler = SourcesHandler(theSources: selectedSources, theApiKey: apiKey, lang: "")
        articles = sourceHandler.articles
        
        if articles.count > 0 {
            performSegue(withIdentifier: "gameSegue3", sender: self)
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
