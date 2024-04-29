//  Aiden Ballou        aiballou@iu.edu
//  Kisheeth Reddivari  kreddiva@iu.edu
//  MacroTrack
//  Submission: April 27. 2024

import UIKit


class NewFoodViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var user: User?
    var appDelegate: AppDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.appDelegate = appDelegate
            user = appDelegate.user
        }
        
        nameTextField.delegate = self
        caloriesTextField.delegate = self
        proteinTextField.delegate = self
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Ensure that the user object is set
        guard let user = user else {
            print("User object is nil.")
            return
        }
        
        // Validate input
        guard let name = nameTextField.text, !name.isEmpty,
              let caloriesText = caloriesTextField.text, !caloriesText.isEmpty,
              let calories = Int(caloriesText),
              let proteinText = proteinTextField.text, !proteinText.isEmpty,
              let protein = Int(proteinText) else {
            print("Invalid input.")
            return
        }
        // Create a new FoodItem and add it to the user's foods
        let newFoodItem = User.FoodItem(name: name, calories: calories, protein: protein)
        user.allLoggedFoods.append(newFoodItem)
        
        // Save the user data to UserDefaults
        appDelegate?.saveUser(user)
        
        NotificationCenter.default.post(name: .userDidUpdateData, object: user)
    }

    // Resign first responder method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // Dismiss keyboard when tapping outside text fields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}



