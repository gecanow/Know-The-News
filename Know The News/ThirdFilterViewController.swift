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
    var selectedSourceIDs = [String]()
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 1 {
            var semiSearchedSources = [[String: String]]()
            for source in allSources {
                let allParts = source["name"]! + source["category"]! + source["language"]! + source["country"]!
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
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
        let subtitle = "\(searchedSources[index]["category"]!) | Country: \(searchedSources[index]["country"]!) | Language: \(searchedSources[index]["language"]!)"
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = subtitle
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("open url?")
        let url = URL(string: searchedSources[indexPath.row]["url"]!)
        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        print(sender.tag)
        if sender.isOn {
            allSources[sender.tag]["chosen"] = "yes"
        } else {
            allSources[sender.tag]["chosen"] = "no"
        }
    }
    
    @IBAction func onTappedBegin(_ sender: Any) {
        articles = [[String: String]]()
        
        selectedSourceIDs = [String]()
        for source in allSources {
            if source["chosen"] == "yes" {
                selectedSourceIDs.append(source["id"]!)
            }
        }
        if selectedSourceIDs.count > 20 {
            self.loadError(problem: "Please select at most 20 sources. (You have \(selectedSourceIDs.count) sources selected.)")
        } else if selectedSourceIDs.count > 0 {
            setAndSearchQuery()
        } else {
            self.loadError(problem: "Please selected at least one source.")
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
        var query = "https://newsapi.org/v2/everything?sources="
        for id in selectedSourceIDs {
            query += id + ","
        }
        query = query.prefix(query.count-1) + "&apiKey=\(apiKey)"
        
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
        print(json["totalResults"])
        for result in json["articles"].arrayValue {
            let title = result["title"].stringValue
            let description = result["description"].stringValue
            let url = result["url"].stringValue
            let date = String(result["publishedAt"].stringValue.prefix(10))
            let sourceName = result["source"]["name"].stringValue
            
            let article = ["title": title, "description": description, "url": url, "sourceName": sourceName, "date": date]
            articles.append(article)
        }
        
        if articles.count > 0 {
            DispatchQueue.main.async {
                [unowned self] in
                self.performSegue(withIdentifier: "gameSegue3", sender: self)
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
