//
//  ConnectionViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import Firebase

class ConnectionViewController: UIViewController {
    // MARK: - view item declaration
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var navBarConnectionView: UINavigationItem!
    
    
    // MARK: - function of the connection
    // Here is the connection function that use the logIn function if the Firebase Controller
    @IBAction func logInButton(_ sender: UIButton) {
        guard let userName = self.emailTextField.text , let password = passwordTextField.text else{
            self.presentEventDialog(withTitle: "No userName or Password Found", andMessage: "you need to enter a UserName and a Password to enter the application", actionEnum : .cancelAction)
            return
        }
        FirebaseController.sharedInstance.logInToApplication(userName: userName, password: password) { (success, error) in
            if let error = error{
                self.presentAlertDialog(withError: error)
            }
            if success{
                if (FirebaseController.sharedInstance.currentUser?.isEmailVerified)!{
                    
                    self.goToIntitiationTourPart()
//                    guard let comicBookPaintingsTourInitiationTabVC = self.storyboard?.instantiateViewController(withIdentifier: "CBPTITabBarController") as? ComicsBookPaintingTourItitiationTabBarController else {return}
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.window?.rootViewController =  comicBookPaintingsTourInitiationTabVC
                }else{
                    self.presentEventDialog(withTitle: "email is not verified", andMessage: "first you need to verified your email address. Please do before entering the application", actionEnum : .cancelAction)
                }
            }else{
                self.presentEventDialog(withTitle: "Wrong Password or UserName", andMessage: "You have enter a wrong password or a wrong user Name. If you don't have an account please click on the new user button", actionEnum : .cancelAction)
            }
        }
    }
    
    func goToIntitiationTourPart(){
        performSegue(withIdentifier: "goToComicBookTourInitiationTabBar", sender: logInButton)
    }
    
    @IBAction func newUserButton(_ sender: UIButton) {
        performSegue(withIdentifier: "newUserSegue", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navBarConnectionView.title = "Comics Painting App Brussels"
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


