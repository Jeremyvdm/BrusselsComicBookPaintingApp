//
//  ComicsBookPaintingTourItitiationTabBarController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 17/11/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import RealmSwift

class ComicsBookPaintingTourItitiationTabBarController: UITabBarController {
    
    var tabBarTitle = ""
    
    // will fetch the current user
    func fetchCurrentUser(){
        var currentUser : UserApp = UserApp()
        FirebaseController.sharedInstance.getUserFromDataBase(handler: {user in
            if user.firstName != "" {
                currentUser = user
                self.findAllComicsPainting(currentUser: currentUser)
            }
        })
    }
    
    // will colect all the comicBook painting of the application from the web or from the inern memory
    func findAllComicsPainting(currentUser : UserApp){
        var ListOfAllComicPaintings : [ComicsBookPainting] = []
        let realm = try! Realm()
        if realm.isEmpty{
            WebServiceControler.fetchComicsBookPainting{
                items in
                ListOfAllComicPaintings += items
                for comicBookPainting in items{
                    try! realm.write {
                        realm.add(comicBookPainting)
                    }
                }
            }
            configuretheViewController(user : currentUser, ListOfAllComicBookPaintings : ListOfAllComicPaintings)
        }else{
            let comicBooksPaintingsFromRealm = realm.objects(ComicsBookPainting.self)
            for comicBookPainting in comicBooksPaintingsFromRealm{
                ListOfAllComicPaintings.append(comicBookPainting)
            }
            configuretheViewController(user : currentUser, ListOfAllComicBookPaintings : ListOfAllComicPaintings)
        }
    }
    
    func configuretheViewController(user : UserApp, ListOfAllComicBookPaintings : [ComicsBookPainting]){
        guard let comicBookPaintingTourIntitationVC = self.storyboard?.instantiateViewController(withIdentifier: "comicBookTourInitiationVC") as? ComicsTourInitiationTableViewController, let userInformationTVC = self.storyboard?.instantiateViewController(withIdentifier: "userInfoVC") as? UserInformationTableViewController, let comicBookPaintingCompleteMapVC = self.storyboard?.instantiateViewController(withIdentifier: "comicsBookPaintingCompleteMapVC") as? ComicsPaintingMapViewController else {return}
        comicBookPaintingTourIntitationVC.ListOfAllComicPaintings = ListOfAllComicBookPaintings
        comicBookPaintingTourIntitationVC.currentUser = user
        comicBookPaintingCompleteMapVC.comicBookPaintings = ListOfAllComicBookPaintings
        comicBookPaintingCompleteMapVC.currentUser = user
        userInformationTVC.allTheComicBookPaintings = ListOfAllComicBookPaintings
        userInformationTVC.currentUser = user
        viewControllers = [comicBookPaintingTourIntitationVC, userInformationTVC, comicBookPaintingCompleteMapVC]
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self as? UITabBarControllerDelegate
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        fetchCurrentUser()
    }
}
