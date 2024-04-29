//
//  SettingsViewController.swift
//  Aiden Ballou        aiballou@iu.edu
//  Kisheeth Reddivari  kreddiva@iu.edu
//  MacroTrack
//  Submission: April 27. 2024

import UIKit
import SpriteKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var calorieTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var stepsTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var appDelegate: AppDelegate? // Reference to the AppDelegate
    var skView: SKView! // SpriteKit View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup for SpriteKit
        setupSpriteKitBackground()
        
        nameTextField.delegate = self
        calorieTextField.delegate = self
        proteinTextField.delegate = self
        stepsTextField.delegate = self
        
        // Reference to the AppDelegate
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        // Fill the text fields with existing user data if available
        if let user = appDelegate?.user {
            nameTextField.text = user.username
            calorieTextField.text = "\(user.goals.caloriesGoal)"
            proteinTextField.text = "\(user.goals.proteinGoal)"
            stepsTextField.text = "\(user.goals.stepsGoal)"
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let calorieText = calorieTextField.text, !calorieText.isEmpty,
              let proteinText = proteinTextField.text, !proteinText.isEmpty,
              let stepsText = stepsTextField.text, !stepsText.isEmpty,
              let caloriesGoal = Int(calorieText),
              let proteinGoal = Int(proteinText),
              let stepsGoal = Int(stepsText)
        else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        if appDelegate?.user == nil {
            appDelegate?.user = User(username: name,
                                     goals: User.UserGoals(caloriesGoal: caloriesGoal, proteinGoal: proteinGoal, stepsGoal: stepsGoal),
                                     currentAmounts: User.CurrentAmounts(currentCalories: 0, currentProtein: 0, currentSteps: 0),
                                     allLoggedFoods: [])
        } else {
            appDelegate?.user?.username = name
            appDelegate?.user?.goals.caloriesGoal = caloriesGoal
            appDelegate?.user?.goals.proteinGoal = proteinGoal
            appDelegate?.user?.goals.stepsGoal = stepsGoal
        }
        
        if let appDelegate = appDelegate, let user = appDelegate.user {
            appDelegate.saveUser(user)
            showAlert(message: "Settings saved successfully")
        }
        
        NotificationCenter.default.post(name: .userDidUpdateData, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Setup SpriteKit View and Scene
    private func setupSpriteKitBackground() {
        skView = SKView(frame: view.bounds)
        view.addSubview(skView)
        view.sendSubviewToBack(skView)

        let scene = SKScene(size: skView.bounds.size)
        scene.backgroundColor = SKColor.lightGray // Set the desired background color here
        skView.presentScene(scene)
    }
}
