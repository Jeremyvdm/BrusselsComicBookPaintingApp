//
//  ComicTourInitiationViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift


class ComicTourInitiationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - variable declaration
    var ListOfAllComicPaintings : [ComicsBookPainting] = []
    var currentUser : UserApp = UserApp()
    var numberOfComicBookPainting : Int = 5
    var numberOfKilometerRadius : Double = 500.00
    var distanceBetweenTwoComicBookPainting : Double = 500.00
    var startingPoint = CLLocation(latitude: 50.838042, longitude: 4.347661)
    let locationManager = CLLocationManager()
    var playerCurentLocation = CLLocation()
    var totalDistance = 0.00
    let realm = try! Realm()
    
    // MARK: - view item declaration and view item action
    
    // here initiation of the number of painting
    @IBAction func numberOfPaintingSegmentControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 1:
            numberOfComicBookPainting = 10
        case 2:
            numberOfComicBookPainting = 15
        case 3:
            numberOfComicBookPainting = 20
        default:
            break
        }
    }
    
    
    // here initiation of the starting location
    @IBAction func startingPointSegmentControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 1:
            startingPoint = CLLocation(latitude: 50.885075, longitude: 4.344140)
        case 2:
            startingPoint = CLLocation(latitude: 50.848553, longitude: 4.350578)
        case 3:
            startingPoint = playerCurentLocation
        default :
            break
        }
        
    }
    
    
    // here is initiation the number of kilometer radius
    @IBAction func numberOfKilimetersRadiusSegmentControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 1:
            numberOfKilometerRadius = 1000.00
        case 2:
            numberOfKilometerRadius = 2000.00
        case 3:
            numberOfKilometerRadius = 4000.00
        default:
            break
        }
    }
    
    // here is the initiation of the distance between two comic book location
    @IBAction func numberOfKilimeterBetweenTwoPaintings(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            distanceBetweenTwoComicBookPainting = 1000.00
        case 2:
            distanceBetweenTwoComicBookPainting = 1500.00
        case 3:
            distanceBetweenTwoComicBookPainting = 2000.00
        default:
            break
        }
    }
    
    @IBAction func goToComicBookTour(_ sender: Any) {
        performSegue(withIdentifier: "goToComicBookTourSegue", sender: sender)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first{
            playerCurentLocation = currentLocation
            locationManager.stopUpdatingLocation()
        }
    }
    
    // MARK: - custum fonction
    
    // here the function will collect the list of comic book paintings with the critera
    // and will return the list to the next view
    func fetchPlayerComicBookTour () -> [ComicsBookPainting]{
        var playerComicBookTour : [ComicsBookPainting] = []
        var locationOfInterestA = startingPoint
        var i = 0
        while i < numberOfComicBookPainting{
            let totalNumberOfComicBookPaintings = UInt32(ListOfAllComicPaintings.count)
            let comicBookPaintingIndex : Int = Int(arc4random_uniform(totalNumberOfComicBookPaintings))
            let comicBookPainting = ListOfAllComicPaintings[comicBookPaintingIndex]
            let comicBookPaintingLocation = CLLocation(latitude: comicBookPainting.lat, longitude: comicBookPainting.lng)
            let distanceFromStartingPoint = startingPoint.distance(from: comicBookPaintingLocation)
            let distanceBetweenTwoPlaceOfInterest = comicBookPaintingLocation.distance(from: locationOfInterestA)
            if(distanceBetweenTwoPlaceOfInterest < distanceBetweenTwoComicBookPainting) && (distanceFromStartingPoint < numberOfKilometerRadius) {
                playerComicBookTour.append(comicBookPainting)
                ListOfAllComicPaintings.remove(at: comicBookPaintingIndex)
                i += 1
            }
            locationOfInterestA = comicBookPaintingLocation
        }
        return playerComicBookTour
    }
    
    // will colect all the comicBook painting of the application from the web or from the inern memory
    func findAllComicsPainting(){
        if realm.isEmpty{
            WebServiceControler.fetchComicsBookPainting{
                items in
                self.ListOfAllComicPaintings += items
                for comicBookPainting in items{
                    try! self.realm.write {
                        self.realm.add(comicBookPainting)
                    }
                }
            }
        }else{
            let comicBooksPaintingsFromRealm = realm.objects(ComicsBookPainting.self)
            for comicBookPainting in comicBooksPaintingsFromRealm{
                ListOfAllComicPaintings.append(comicBookPainting)
            }
        }
    }
    
    // will fetch the current user
    func fetchCurrentUser(){
        FirebaseController.sharedInstance.getUserFromDataBase(handler: {user in
            if user.firstName != "" {
                self.currentUser = user
            }
        })
    }
    
    
    // MARK: - function of the view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        findAllComicsPainting()
        fetchCurrentUser()
        locationManager.delegate = self as CLLocationManagerDelegate
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if realm.isEmpty{
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
        if let comicPaintingMapSegue = segue.destination as? ComicsPaintingMapViewController{
            comicPaintingMapSegue.comicBookPaintings = self.ListOfAllComicPaintings
        }
        
        if let comicPaintingTourSegue = segue.destination as? ComicTourTableViewController{
            comicPaintingTourSegue.playerListOfComicBookPaintings = fetchPlayerComicBookTour()
            comicPaintingTourSegue.currentUser = currentUser
        }
        
        if let userInformationSegue = segue.destination as? UserInformationTableViewController{
            userInformationSegue.allTheComicBookPaintings = ListOfAllComicPaintings
            userInformationSegue.currentUser = currentUser
        }
    }
    
}
