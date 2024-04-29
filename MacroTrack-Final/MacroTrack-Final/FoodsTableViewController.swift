//
//  FoodsTableViewController.swift
//  Aiden Ballou        aiballou@iu.edu
//  Kisheeth Reddivari  kreddiva@iu.edu
//  MacroTrack
//  Submission: April 27. 2024
//

import UIKit

class FoodsTableViewController: UITableViewController {
    var appDelegate: AppDelegate?
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Foods"

        // Retrieve the User object from the AppDelegate
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            user = appDelegate.user
        }
        NotificationCenter.default.addObserver(self, selector: #selector(userDidUpdateData(_:)), name: Notification.Name("UserDidUpdateDataNotification"), object: nil)
        // Reload the table view data after setting the user
        tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the count of user's logged foods plus one for the "Create" cell
        return (user?.allLoggedFoods.count ?? 0) + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if the index path is for the "Create" cell
        if indexPath.row == user?.allLoggedFoods.count {
            let createCell = tableView.dequeueReusableCell(withIdentifier: "Create", for: indexPath)
            // Configure the "Create" cell
            //createCell.textLabel?.text = "Add New Food"
            return createCell
        } else {
            // Configure regular cells using user's logged foods
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            if let foodItem = user?.allLoggedFoods[indexPath.row] {
                cell.textLabel?.text = foodItem.name
                cell.detailTextLabel?.text = "Calories: \(foodItem.calories), Protein: \(foodItem.protein)"
                
                // Add the "+" button
                let addButton = UIButton(type: .system)
                addButton.setTitle("+", for: .normal)
                addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
                let addButtonWidth: CGFloat = 40
                let addButtonHeight: CGFloat = 40
                addButton.frame = CGRect(x: 0, y: 0, width: addButtonWidth, height: addButtonHeight)
                addButton.tag = indexPath.row

                // Add another button to the left of the "+" button
                let minusButton = UIButton(type: .system)
                minusButton.setTitle("-", for: .normal)
                minusButton.addTarget(self, action: #selector(minusButtonTapped(_:)), for: .touchUpInside)
                let minusButtonWidth: CGFloat = 60
                let minusButtonHeight: CGFloat = 40
                minusButton.frame = CGRect(x: 0, y: 0, width: minusButtonWidth, height: minusButtonHeight)
                minusButton.tag = indexPath.row
                
                // Create a container view to hold both buttons
                let buttonsContainerView = UIView(frame: CGRect(x: 0, y: 0, width: addButtonWidth + minusButtonWidth, height: addButtonHeight))
                addButton.frame.origin.x = minusButtonWidth // Position the "+" button to the right of the "Other" button
                buttonsContainerView.addSubview(minusButton)
                buttonsContainerView.addSubview(addButton)
                
                cell.accessoryView = buttonsContainerView
            }
            return cell
        }
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Set height for the "Create" cell
        if indexPath.row == user?.allLoggedFoods.count {
            return 150
        } else {
            // Set height for regular cells
            return 64
        }
    }

    // MARK: - Actions
    @objc func addButtonTapped(_ sender: UIButton) {
        guard let foodItem = user?.allLoggedFoods[sender.tag] else {
                print("Error: Unable to retrieve food item")
                return
        }
        print("adding")
        user?.addFoodItemToToday(food: foodItem)
        // Reload the table data
        tableView.reloadData()
        guard let user = user else {
            print("User object is nil.")
            return
        }
        appDelegate?.saveUser(user)
    }

    @objc func minusButtonTapped(_ sender: UIButton) {
        
        // Safely unwrap?
        let row = sender.tag
        user?.removeFoodItemFromAll(at: row)
        tableView.reloadData()
        guard let user = user else {
            print("User object is nil.")
            return
        }
        appDelegate?.saveUser(user)
    }
        
    @objc func userDidUpdateData(_ notification: Notification) {
        tableView.reloadData()
    }
}
