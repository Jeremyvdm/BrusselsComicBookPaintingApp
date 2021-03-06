//
//  VictoryViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit

class VictoryViewController: UIViewController {
    
    @IBOutlet weak var victoryLabel: UILabel!
    
    @IBOutlet weak var victoryNavBar: UINavigationItem!
    
    var numberOfComicBookPaintingPassed : Int?
    var numberOfComicBookPaintingReached : Int?
    
    @IBAction func startAgainButton(_ sender: Any) {
        let comicBookPaintingAppStroryBoard = UIStoryboard(name: "Main", bundle: nil)
        let comicBookTourInitiationVC = comicBookPaintingAppStroryBoard.instantiateViewController(withIdentifier: "comicBookTourInitiationVC") as! ComicsTourInitiationTableViewController
        self.navigationController?.pushViewController(comicBookTourInitiationVC, animated: true)
    }
    @IBAction func quitButton(_ sender: Any) {
        let comicBookPaintingAppStroryBoard = UIStoryboard(name: "Main", bundle: nil)
        let connectionVC = comicBookPaintingAppStroryBoard.instantiateViewController(withIdentifier: "connectionVC") as! ConnectionViewController
        FirebaseController.sharedInstance.logOutFromTheApplicatio()
        self.navigationController?.pushViewController(connectionVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        victoryNavBar.hidesBackButton = true
        victoryNavBar.title = "Victory!!!!"
        victoryLabel.text = "You completed your Comic Book Painting Tour Congratulation! \n You have passed only \(numberOfComicBookPaintingPassed!) comics book paintings and you have reached \(numberOfComicBookPaintingReached!)! \n What would you like to do? \n click on the play again button to go back to create an other tour. \n click on qui to go back at the login window to quit the application!"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

