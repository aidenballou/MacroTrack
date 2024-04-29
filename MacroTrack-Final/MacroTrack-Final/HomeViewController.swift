//
//  HomeViewController.swift
//  Aiden Ballou        aiballou@iu.edu
//  Kisheeth Reddivari  kreddiva@iu.edu
//  MacroTrack
//  Submission: April 27. 2024
//

import UIKit

class HomeViewController: UIViewController {
    var appDelegate: AppDelegate?
    var userRef: User?
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var calorieProgress: CircularProgressView!
    @IBOutlet weak var proteinProgress: CircularProgressView!
    @IBOutlet weak var stepsProgress: CircularProgressView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var foodsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.userRef = self.appDelegate?.user
        // Set initial data
        updateUI()
        
        // Observe user data update notification
        NotificationCenter.default.addObserver(self, selector: #selector(userDidUpdateData(_:)), name: .userDidUpdateData, object: nil)
        calorieProgress.trackColor = UIColor.white
        calorieProgress.progressColor = UIColor.green
        proteinProgress.trackColor = UIColor.white
        proteinProgress.progressColor = UIColor.green
        stepsProgress.trackColor = UIColor.white
        stepsProgress.progressColor = UIColor.green
        
        if userRef != nil {
            foodsTableView.dataSource = self
        } else {
            // Handle eror if userRef is nil
            print("User is nil. Unable to set data source.")
        }
        
        foodsTableView.reloadData()
        
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }
    @objc func userDidUpdateData(_ notification: Notification) {
        updateUI()
    }
    func updateUI() {
        if let user = userRef {
            welcomeLabel.text = "Welcome, \(user.username)"
            calorieLabel.text = "\(user.currentAmounts.currentCalories)"
            proteinLabel.text = "\(user.currentAmounts.currentProtein) g"
            stepsLabel.text = "\(user.currentAmounts.currentSteps)"
            
            // Update progress views based on user's data
            calorieProgress.setProgress(duration: 1.0, value: (Float(user.currentAmounts.currentCalories) / Float(user.goals.caloriesGoal)))
            proteinProgress.setProgress(duration: 1.0, value: (Float(user.currentAmounts.currentProtein) / Float(user.goals.proteinGoal)))
            stepsProgress.setProgress(duration: 1.0, value: (Float(user.currentAmounts.currentSteps) / Float(user.goals.stepsGoal)))
        } else {
            // Handle the case when userRef is nil
            welcomeLabel.text = "Welcome"
            calorieLabel.text = "N/A"
            proteinLabel.text = "N/A"
            stepsLabel.text = "N/A"
            
            calorieProgress.setProgress(duration: 1.0, value: 0)
            proteinProgress.setProgress(duration: 1.0, value: 0)
            stepsProgress.setProgress(duration: 1.0, value: 0)
        }
        foodsTableView.reloadData()
    }

    deinit {
        // Remove observer
        NotificationCenter.default.removeObserver(self, name: .userDidUpdateData, object: nil)
    }
}
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if userRef?.foodsEatenToday.isEmpty ?? true {
            // Handle the case where foodsEatenToday is empty
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoneCell", for: indexPath)
            cell.textLabel?.text = "No food items logged today"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            // Configure the cell with the food item details
            if let foodItem = userRef?.foodsEatenToday[indexPath.row] {
                cell.textLabel?.text = foodItem.name
                cell.detailTextLabel?.text = "Calories: \(foodItem.calories), Protein: \(foodItem.protein)"
            }
            
            let deleteButton = UIButton(type: .system)
            deleteButton.setTitle("-", for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            deleteButton.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
            deleteButton.tag = indexPath.row
            deleteButton.tag = indexPath.row
            cell.accessoryView = deleteButton
            
            return cell
        }
    }

    @objc func deleteButtonTapped(_ sender: UIButton) {
        // Safely unwrap?
        let row = sender.tag
        userRef?.removeFoodItemFromToday(at: row)
        foodsTableView.reloadData()
        guard let user = userRef else {
            print("User object is nil.")
            return
        }
        appDelegate?.saveUser(user)
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let foodsEatenToday = userRef?.foodsEatenToday, !foodsEatenToday.isEmpty {
            return foodsEatenToday.count
        } else {
            return 1
        }
    }
}
