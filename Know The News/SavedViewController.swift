//
//  SavedViewController.swift
//  Know The News
//
//  Created by Necanow on 7/10/18.
//  Copyright © 2018 EcaKnowGames. All rights reserved.
//

import UIKit
let savedArticlesID = "savedArticles"

class SavedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var savedArticles = [[String:String]]()
    let defaults = UserDefaults.standard
    
    //=========================================
    // VIEW DID LOAD
    //=========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.start()
    }
    
    //=========================================
    // Retrieves the saved articles
    //=========================================
    func start() {
        if let savedData = defaults.object(forKey: savedArticlesID) as? Data {
            if let decoded = try? JSONDecoder().decode([[String: String]].self, from: savedData) {
                savedArticles = decoded
            }
        }
        tableView.reloadData()
    }
    
    //=========================================
    // Alerts the user of a loading error
    //=========================================
    func loadError() {
        DispatchQueue.main.async {
            [unowned self] in
            //(rest of method goes here)
            
            let alert = UIAlertController(title: "Loading Error",
                                          message: "There was a problem loading the news feed",
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //===============================//
    // TABLE VIEW DELEGATE FUNCTIONS //
    //===============================//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let article = savedArticles[indexPath.row]
        
        cell.textLabel?.text = article["title"]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        cell.detailTextLabel?.text = article["description"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: savedArticles[indexPath.row]["url"]!)
        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedArticles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveSaved()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let objectToMove = savedArticles.remove(at: sourceIndexPath.row)
        savedArticles.insert(objectToMove, at: destinationIndexPath.row)
        saveSaved()
    }
    
    //=========================================
    // Handles when the user taps edit
    //=========================================
    @IBAction func onTappedEdit(_ sender: UIButton) {
        if sender.titleLabel?.text == "Edit" {
            tableView.setEditing(true, animated: true)
            sender.setTitle("Done", for: .normal)
        } else {
            tableView.setEditing(false, animated: true)
            sender.setTitle("Edit", for: .normal)
            
        }
    }
    
    //=================================================
    // Saves the saved articles array to user defaults
    //=================================================
    func saveSaved() {
        if let encoded = try? JSONEncoder().encode(savedArticles) {
            defaults.set(encoded, forKey: savedArticlesID)
        }
    }
}
