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
    var articles : [[String: String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        
        cell.detailTextLabel?.text = "Solved:\n0:00.00"
        cell.detailTextLabel?.font = UIFont(name: "CaslonOS-Regular", size: 12.0)
        return cell
    }
}
