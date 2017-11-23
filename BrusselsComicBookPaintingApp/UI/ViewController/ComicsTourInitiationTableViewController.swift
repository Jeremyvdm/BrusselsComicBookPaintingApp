//
//  ComicsTourInitiationTableViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 23/11/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift

class ComicsTourInitiationTableViewController: UITableViewController, CLLocationManagerDelegate {

    // MARK: - variable declaration
    var ListOfAllComicPaintings : [ComicsBookPainting] = []
    var currentUser : UserApp = UserApp()
    var numberOfComicBookPainting : Int = 5
    var numberOfKilometerRadius : Double = 1000.00
    var distanceBetweenTwoComicBookPainting : Double = 500.00
    var startingPoint = CLLocation(latitude: 50.838042, longitude: 4.347661)
    let locationManager = CLLocationManager()
    var totalDistance = 0.00
    let realm = try! Realm()
    
    // MARK: - view item declaration and view item action
    
    @IBOutlet weak var goToComicsTourInfo: UIButton!
    @IBAction func goToComicBookTourTabBC(_ sender: Any) {
        performSegue(withIdentifier: "goToComicsBookPaintingTourInfoSegue", sender: goToComicsTourInfo)
    }
    
    // here initiation of the number of painting
    @IBAction func numberOfPaintingSegmentControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            numberOfComicBookPainting = 5
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
        case 0:
            startingPoint = CLLocation(latitude: 50.838042, longitude: 4.347661)
        case 1:
            startingPoint = CLLocation(latitude: 50.885075, longitude: 4.344140)
        case 2:
            startingPoint = CLLocation(latitude: 50.848553, longitude: 4.350578)
        case 3:
            startingPoint = getUserLocation()
        default :
            break
        }
        
    }
    
    
    // here is initiation the number of kilometer radius
    @IBAction func numberOfKilimetersRadiusSegmentControl(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            numberOfKilometerRadius = 1000.00
        case 1:
            numberOfKilometerRadius = 2000.00
        case 2:
            numberOfKilometerRadius = 3000.00
        case 3:
            numberOfKilometerRadius = 4000.00
        default:
            break
        }
    }
    
    // here is the initiation of the distance between two comic book location
    @IBAction func numberOfKilimeterBetweenTwoPaintings(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            distanceBetweenTwoComicBookPainting = 500.00
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
    
    
    
    // MARK: - function of the view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        locationManager.delegate = self as CLLocationManagerDelegate
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationItem.hidesBackButton = true
        self.parent?.navigationItem.title = "Comics Painting Tour Initiation"
    }
    
    func getUserLocation()->CLLocation{
        guard let currentLocation = (UIApplication.shared.delegate as! AppDelegate).lastSavedLocation else {return CLLocation()}
        return currentLocation
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let comicBookPaintingTourTabVC = segue.destination as? ComicBookPaintingTourTabBarController{
            comicBookPaintingTourTabVC.playerListOfComicBookPaintings = fetchPlayerComicBookTour()
            comicBookPaintingTourTabVC.currentUser = currentUser
            comicBookPaintingTourTabVC.startingLocation = startingPoint
        }
    }
    
}
