//
//  HistoryViewController.swift
//  Aiden Ballou        aiballou@iu.edu
//  Kisheeth Reddivari  kreddiva@iu.edu
//  MacroTrack
//  Submission: April 27. 2024
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safely unwrap the appDelegate and user
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            user = appDelegate.user
        }
        // Set the data source only if user is not nil
        if user != nil {
            tableView.dataSource = self
        } else {
            // Handle the scenario where user is nil
            print("User is nil. Unable to set data source.")
        }
        
        tableView.reloadData()
    }

}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Check if user's history is not nil and not empty
        if let history = user?.history, !history.isEmpty {
            return history.count
        } else {
            // If user or its history is nil, or history is empty, return 1
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        
        // Check if user's history is not nil and index is within bounds
        if let history = user?.history, indexPath.row < history.count {
            let dailySummary = history[indexPath.row]
            cell.dateLabel.text = formatDate(dailySummary.date)
            cell.caloriesLabel.text = "Calories: \(dailySummary.caloriesEaten)"
            cell.proteinLabel.text = "Protein: \(dailySummary.proteinConsumed)"
            cell.stepsLabel.text = "Steps: \(dailySummary.stepsTaken)"
        } else {
            // If user or history is nil, or index is out of bounds, set default values or empty strings
            cell.dateLabel.text = "No history available"
            cell.caloriesLabel.text = ""
            cell.proteinLabel.text = ""
            cell.stepsLabel.text = ""
        }
        
        return cell
    }
    
    // Helper method to format date
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    @objc func userDidUpdateData(_ notification: Notification) {
        tableView.reloadData()
    }
}
