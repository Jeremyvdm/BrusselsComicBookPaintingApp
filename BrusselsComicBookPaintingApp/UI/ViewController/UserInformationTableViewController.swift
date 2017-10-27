//
//  UserInformationTableViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserInformationTableViewController: UITableViewController {
    // MARK: - variable declaration
    var allTheComicBookPaintings : [ComicsBookPainting] = []
    var currentUser : UserApp = UserApp()
    var listOfUserComicBookPaintingTourDictionnary :  [String : [String]] = [:]
    var listOfUserInformation : [String : String] = [:]
    var listOfDictionnaryToDisplay : [String : [String : Any]] = [:]
    
    
    // MARK: - view item declaration and view item action
    @IBOutlet var userIformationTableView: UITableView!
    
    @IBAction func resetPassword(_ sender: UIBarButtonItem) {
        let email : String = currentUser.email
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error
            {
                self.presentAlertDialog(withError: error)
            }
            else
            {
                self.presentEventDialog(withTitle: "Email has been send", andMessage: "An email has been sent to you to modify you're password", actionEnum: .continueAction)
            }
        }
    }
    
    // MARK: - custom function
    
    //will set the user dictionary that contain all the user information
    func getUserInformation(){
        listOfUserInformation["first Name "] = currentUser.firstName
        listOfUserInformation["last Name "] = currentUser.lastName
        listOfUserInformation["email "] = currentUser.email
        listOfUserInformation["address "] = currentUser.address
        let PlayerListOfComicBookPaintingTour = currentUser.listOfComicBookPaintingsTours
        for comicBookPaintingTour in PlayerListOfComicBookPaintingTour{
            listOfUserComicBookPaintingTourDictionnary[comicBookPaintingTour.comicBooksPaintingsTourName] = comicBookPaintingTour.listOfComicBookPaintingsTitle
        }
        listOfDictionnaryToDisplay["User Information"] = listOfUserInformation
        listOfDictionnaryToDisplay["list of Comic book Painting Tour"] = listOfUserComicBookPaintingTourDictionnary
    }
    
    
    // wil fetch and declare a dictionnary that will contain all the comic book tour of the application
    func fetchTheListOfComicBooksPaintingsFromDictionary(index : Int) -> [ComicsBookPainting]{
        var listOfComicBookPaintingsOfTheTour : [ComicsBookPainting] = []
        let listOfUserComicBookPaintingTour = Array(listOfUserComicBookPaintingTourDictionnary.keys)
        let comicBookPaintingTourName = listOfUserComicBookPaintingTour[index]
        let listOfComicBookPaintingsTitle  : [String] = listOfUserComicBookPaintingTourDictionnary[comicBookPaintingTourName]!
        for i in 0 ..< listOfComicBookPaintingsTitle.count {
            for comicBookPainting in allTheComicBookPaintings{
                if comicBookPainting.comicsPaintingTitle == listOfComicBookPaintingsTitle[i]{
                    listOfComicBookPaintingsOfTheTour.append(comicBookPainting)
                }
            }
        }
        return listOfComicBookPaintingsOfTheTour
    }
    
    // MARK: - function view
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInformation()
        userIformationTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return listOfDictionnaryToDisplay.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var row = 0
        if section == 0{
            row = listOfUserInformation.count
        }
        if section == 1{
            row = listOfUserComicBookPaintingTourDictionnary.count
        }
        return row
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return Array(listOfDictionnaryToDisplay.keys)[section]
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section == 0{
            let userCell = tableView.dequeueReusableCell(withIdentifier: "UserInformationIdentifier", for: indexPath) as! UserInformationUITableViewCell
            let listOfKeys : [String] = Array(listOfUserInformation.keys)
            let key : String = listOfKeys[indexPath.row]
            userCell.userInformationKeyLabel.text = key
            userCell.userInformationValueLabel.text = listOfUserInformation[key]
            cell = userCell
        }
        else {
            let tourTitleCell = tableView.dequeueReusableCell(withIdentifier: "comicBookPaintingTourNameIdentifier", for: indexPath) as! listOfComicBookPaintnigsTourTableViewCell
            let listOFComicBookPaintingTourName = Array(listOfUserComicBookPaintingTourDictionnary.keys)
            tourTitleCell.comicBookPaintingTourNameLabel.text = listOFComicBookPaintingTourName[indexPath.row]
            cell = tourTitleCell
        }
        
        // Configure the cell...
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comicBookPaintingAppStroryBoard = UIStoryboard(name: "Main", bundle: nil)
        let listOfComicBookPaintingsTBVC = comicBookPaintingAppStroryBoard.instantiateViewController(withIdentifier: "listOfComicBookPaintingsTBVC") as! ListOfPaintingTourTableViewController
        listOfComicBookPaintingsTBVC.playerComicBooksList = fetchTheListOfComicBooksPaintingsFromDictionary(index: indexPath.row)
        self.navigationController?.pushViewController(listOfComicBookPaintingsTBVC, animated: true)
    }
}
