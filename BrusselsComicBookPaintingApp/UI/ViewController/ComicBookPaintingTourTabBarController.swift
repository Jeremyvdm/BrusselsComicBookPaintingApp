//
//  ComicBookPaintingTourTabBarController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 21/11/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import CoreLocation

class ComicBookPaintingTourTabBarController: UITabBarController {
    var playerListOfComicBookPaintings : [ComicsBookPainting] = []
    var currentUser : UserApp = UserApp()
    var playerLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self as? UITabBarControllerDelegate
        // Do any additional setup after loading the view.
        guard let lastPlayerLocation = (UIApplication.shared.delegate as! AppDelegate).lastSavedLocation else{return}
        self.playerLocation = lastPlayerLocation
        setUpViewController()
    }
    
    
    func setUpViewController(){
        guard let comicsBookPaintingTourInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "comicsBookPaintingTourInfoVC") as? ComicTourTableViewController, let comicsBookPaintingTourListVC = self.storyboard?.instantiateViewController(withIdentifier: "comicsBookPaintingTourListVC") as? ListOfPaintingTourTableViewController, let comicsBookPaintingTourMapVC = self.storyboard?.instantiateViewController(withIdentifier: "comicsBookPaintingTourMapVC") as? ComicBookPaintingTourMapViewController else{return}
        comicsBookPaintingTourInfoVC.playerListOfComicBookPaintings = playerListOfComicBookPaintings
        comicsBookPaintingTourInfoVC.currentUser = currentUser
        comicsBookPaintingTourInfoVC.playerLocation = playerLocation
        comicsBookPaintingTourListVC.playerComicBooksList = playerListOfComicBookPaintings
        comicsBookPaintingTourMapVC.listOfComicBookPaintings = playerListOfComicBookPaintings
        comicsBookPaintingTourMapVC.startingPointLocation = playerLocation
        viewControllers = [comicsBookPaintingTourInfoVC, comicsBookPaintingTourListVC, comicsBookPaintingTourMapVC]
    }
    
}
