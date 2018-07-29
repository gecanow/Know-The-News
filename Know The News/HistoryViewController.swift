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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
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
        cell.backgroundColor = .clear
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        if let solveTime = article["timeToComplete"] {
            cell.detailTextLabel?.text = "Solved in \(solveTime)"
            cell.backgroundColor = .green
        } else {
            cell.detailTextLabel?.text = "Unsolved"
        }
        cell.detailTextLabel?.font = UIFont(name: "CaslonOS-Regular", size: 12.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let article = articles[indexPath.row]
        
        print("will eventually save \(article["title"]!)")
    }
}
