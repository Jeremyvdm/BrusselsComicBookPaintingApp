//
//  NewUserTableViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import Firebase

class NewUserTableViewController: UITableViewController {
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressLine1TextField: UITextField!
    @IBOutlet weak var addressLine2TextField: UITextField!
    
    // The confirm button will do two thing he will use the add new user function of the firebase controller and he will add the user to the firebase database enter the application the player need to log in the connection view
    
    @IBAction func confirmButton(_ sender: UIButton) {
        guard  let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let addressLine1 = addressLine1TextField.text, let addressLine2 = addressLine2TextField.text  else{
            self.presentEventDialog(withTitle: "No userName or Password Found", andMessage: "you need to enter a UserName and a Password to enter the application", actionEnum: .cancelAction)
            return
        }
        let address = addressLine1 + " \n " + addressLine2
        // password verification
        if password != confirmPassword{
            self.presentEventDialog(withTitle: "password doesn't match", andMessage: "The password and the confirmPassword you have enter are not the same!", actionEnum: .cancelAction)
        }else{
            // firebase new user function
            FirebaseController.sharedInstance.createANewUser(userName: email, password: password) { (success, error) in
                if let error = error{
                    self.presentAlertDialog(withError: error)
                }
                if success{
                    self.presentEventDialog(withTitle: "User created", andMessage: "You're User has been successfully created please confrim your account with the comfirmation email that has been send. Then log on to the app.", actionEnum: .continueAction)
                    // add the user to the database
                    FirebaseController.sharedInstance.createUserAppAndStoreApp(email: email, lastName: lastName, firstName: firstName, address: address)
                    
                }else{
                    self.presentEventDialog(withTitle: "problem with userName", andMessage: "You have enter a User Name that all ready exists", actionEnum : .cancelAction)
                }
            }
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
