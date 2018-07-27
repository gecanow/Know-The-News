//
//  ThirdFilterViewController.swift
//  Know The News
//
//  Created by Necanow on 7/26/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class ThirdFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var allSources = [[String: String]]()
    var searchedSources = [[String: String]]()
    var selectedSources = [[String: String]]()
    
    var articles = [[String: String]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    //=========================================
    // VIEW DID LOAD
    //=========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = titleAttributes
        tableView.delegate = self
        tableView.dataSource = self
        
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
            
            let source = ["name": name, "category": category, "url": url, "language": language, "country": country]
            allSources.append(source)
        }
        searchedSources = allSources
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        let index = indexPath.row
        
        //here is programatically switch make to the table view
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = index // for detect which row switch Changed
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        let title = searchedSources[index]["name"]
        let subtitle = searchedSources[index]["type"] //?
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = subtitle
        
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        print(sender.tag)
    }
    
    @IBAction func onTappedBegin(_ sender: Any) {
        articles = [[String: String]]()
        if selectedSources.count > 0 {
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
        let query = "https://newsapi.org/v2/everything?"
        
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
                self.performSegue(withIdentifier: "gameSegue2", sender: self)
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
