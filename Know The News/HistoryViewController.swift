//
//  HistoryViewController.swift
//  Know The News
//
//  Created by Necanow on 7/28/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var articles = [[String: String]]()
    var allArticles = [[String: String]]()
    var finishedArticles = [[String: String]]()
    var finishedArtCount = 0
    
    var savedArticles = [[String: String]]()
    var defaults = UserDefaults.standard
    var customAlert = CustomAlertView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<finishedArtCount { finishedArticles.append([String: String]()) }
        for art in allArticles {
            if art["isFinished"]! != "false" {
                finishedArticles[Int(art["isFinished"]!)!] = art
            }
        }
        finishedArticles.reverse() // most recent show first
        finishedArticles.remove(at: 0) // remove the current article
        articles = finishedArticles // automatically selected "Seen in Game"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let savedData = defaults.object(forKey: savedArticlesID) as? Data {
            if let decoded = try? JSONDecoder().decode([[String: String]].self, from: savedData) {
                savedArticles = decoded
            }
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let article = articles[indexPath.row]
        
        let title = article["title"]!
        let source = article["sourceName"]!
        
        cell.textLabel?.text = "\(source) reports: \"\(title)\""
        cell.textLabel?.font = UIFont(name: "CaslonOS-Regular", size: 14.0)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        if article["isFinished"]! == "false" {
            cell.detailTextLabel?.text = "Unseen"
            cell.detailTextLabel?.backgroundColor = .gray
        } else if article["timeToComplete"]!.count > 0 {
            cell.detailTextLabel?.text = "Solved in \(article["timeToComplete"]!)"
            cell.detailTextLabel?.backgroundColor = .green
        } else {
            cell.detailTextLabel?.text = "Unsolved"
            cell.detailTextLabel?.backgroundColor = .yellow
        }
        cell.detailTextLabel?.font = UIFont(name: "CaslonOS-Regular", size: 12.0)
        
        if savedArticles.contains(article) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let article = articles[indexPath.row]
        
        if savedArticles.contains(article) {
            print("'tis already saved.")
        } else {
            savedArticles.insert(article, at: 0)
            saveSaved()
            cell.accessoryType = .checkmark
            customAlert.createAndDisplaySavedAlert(self.view)
        }
        tableView.reloadData()
    }
    
    @IBAction func onTappedSegmentedControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            articles = finishedArticles
        } else {
            articles = allArticles
        }
        tableView.reloadData()
    }
    
    //=========================================
    // Saves the saved articles to defaults
    //=========================================
    func saveSaved() {
        if let encoded = try? JSONEncoder().encode(savedArticles) {
            defaults.set(encoded, forKey: savedArticlesID)
        }
    }
}
