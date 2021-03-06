//
//  GameViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import AlamofireImage
import MapKit

class GameViewController: UIViewController, TakeAPictureViewControllerDelegate, CLLocationManagerDelegate {
    
    var listOfComicBookPaintingOfTheTour : [ComicsBookPainting] = []
    var gameComicBookPainting : ComicsBookPainting = ComicsBookPainting()
    var gameComicBookPaintingIndex : Int = 0
    var locationManager = CLLocationManager()
    var numbeerOfComicBOokPaintingPassed = 0
    var numbeerOfComicBOokPaintingReached = 0
    var oldPlayerLocation = CLLocation()
    var oldPlayerLocationCicurlarRegion = CLCircularRegion()
    var currentPlayerLocation: CLLocation?{
        didSet{
            playTheGameAndGetTheDisanceTF(playerCurrentLocation: self.currentPlayerLocation!, gameComicBookPainting: gameComicBookPainting)
        }
    }
    var firstDistance = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentPlayerLocation = (UIApplication.shared.delegate as! AppDelegate).lastSavedLocation
        
        NotificationCenter.default.addObserver(forName: .onUserPositionChanged, object: nil, queue: OperationQueue.main) { (notification) in
            if let newLocation = notification.userInfo?["lastLocation"] as? CLLocation{
                self.currentPlayerLocation = newLocation
            }
        }
    }
    
    @IBOutlet weak var comicBookPaintingImageView: UIImageView!
    @IBOutlet weak var comicBookPaintingInfoAdressLabel: UILabel!
    @IBOutlet weak var comicBookPaintnigInfoDistanceLabel: UILabel!
    
    @IBOutlet weak var gameViewNavBar: UINavigationItem!
    
    @IBAction func goTheNextComicBookPainting(_ sender: Any) {
        numbeerOfComicBOokPaintingPassed += 1
        gameComicBookPaintingIndex += 1
        firstDistance = 0.0
        continueTheGame(gameComicBookPaintingIndex : gameComicBookPaintingIndex)
        playTheGameAndGetTheDisanceTF(playerCurrentLocation : self.currentPlayerLocation!, gameComicBookPainting : gameComicBookPainting)
    }
    
    @IBAction func navigationGuidanceButton(_ sender: Any) {
        let ComicBookPainting2DCoordonate  = CLLocationCoordinate2DMake(gameComicBookPainting.lat, gameComicBookPainting.lng)
        let regionDistance = 1000.00
        let regionSpan = MKCoordinateRegionMakeWithDistance(ComicBookPainting2DCoordonate, regionDistance, regionDistance)
        let options = [MKLaunchOptionsMapCenterKey : NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan : regionSpan.span)]
        let placeMark = MKPlacemark(coordinate :ComicBookPainting2DCoordonate)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = gameComicBookPainting.comicsPaintingTitle
        mapItem.openInMaps(launchOptions: options)
    }
    
    func passToNextPanitng(comicsPaintingIndex: Int) {
        self.gameComicBookPaintingIndex = gameComicBookPaintingIndex + 1
        continueTheGame(gameComicBookPaintingIndex: gameComicBookPaintingIndex)
    }
    
    
    func continueTheGame(gameComicBookPaintingIndex : Int){
        if gameComicBookPaintingIndex < listOfComicBookPaintingOfTheTour.count{
            gameComicBookPainting = listOfComicBookPaintingOfTheTour[gameComicBookPaintingIndex]
            setDifferentViewElementOfTheGame(gameComicBookPainting: gameComicBookPainting)
        }else{
            performSegue(withIdentifier: "victorySegue", sender: view)
        }
    }
    
    
    func setDifferentViewElementOfTheGame (gameComicBookPainting : ComicsBookPainting){
        
        let gameComcBookPaintingTitle = gameComicBookPainting.comicsPaintingTitle
        let gameComcBookPaintingImageUrlOpt = gameComicBookPainting.comicsPaintingImageURL
        
        gameViewNavBar.title! = gameComcBookPaintingTitle
        guard let gameComcBookPaintingImageUrl = gameComcBookPaintingImageUrlOpt else{return}
        comicBookPaintingImageView.af_setImage(withURL: gameComcBookPaintingImageUrl)
        
        findTheAdressOfTheComicBookPainting(gameComicBookpainting: gameComicBookPainting)
        
    }
    
    
    func findTheAdressOfTheComicBookPainting(gameComicBookpainting : ComicsBookPainting) {
        let locationServiceController = LocationServiceController(name: gameComicBookpainting.comicsPaintingTitle, latitude: gameComicBookPainting.lat, longitude: gameComicBookPainting.lng)
        var gameComicBookPaintingAdressText = ""
        var addressOfTheGameComicBookPaintng = ""
        locationServiceController.fetchPlacemark(){(success, error) -> Void in
            guard let address : String = locationServiceController.formatedAddress else
            {
                self.presentAlertDialog(withError: error!)
                return
            }
            addressOfTheGameComicBookPaintng = address
            gameComicBookPaintingAdressText = "\n the address of the game comic book painting is \n \(addressOfTheGameComicBookPaintng)"
            self.comicBookPaintingInfoAdressLabel.text = gameComicBookPaintingAdressText
        }
    }
    
    func playTheGameAndGetTheDisanceTF(playerCurrentLocation : CLLocation, gameComicBookPainting : ComicsBookPainting){
        let gameComicBookPaintingLocation = CLLocation(latitude: gameComicBookPainting.lat, longitude: gameComicBookPainting.lng)
        var walkingDistanceToThePainting = 0.00
        let comicsPaintingRegion = CLCircularRegion(center: gameComicBookPaintingLocation.coordinate, radius: 6, identifier: "gameComicBookPaitingGeoFencing")
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: playerCurrentLocation.coordinate))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: gameComicBookPaintingLocation.coordinate))
        directionRequest.transportType = .walking
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: { (response, error) in
            guard let route = response?.routes.first else{return}
            walkingDistanceToThePainting = route.distance
            
            let walkingDistanceToThePaintingDiv1000 = walkingDistanceToThePainting/1000
            let walkingDistanceToThePaintingRounded = (walkingDistanceToThePaintingDiv1000*1000).rounded()/1000
            if self.firstDistance == 0{
                AppDelegate.DisplayInfo(distance: walkingDistanceToThePaintingRounded, fromNewLocation: playerCurrentLocation)
                let gameComicBookPaintingDistanceText = " you are at \(walkingDistanceToThePaintingRounded) km from the painting"
                self.comicBookPaintnigInfoDistanceLabel.text = gameComicBookPaintingDistanceText
                self.firstDistance = walkingDistanceToThePaintingRounded
                self.oldPlayerLocation = self.currentPlayerLocation!
                self.oldPlayerLocationCicurlarRegion = CLCircularRegion(center: self.oldPlayerLocation.coordinate, radius: 20, identifier: "geoFencingforComicsPainting")
            }else if (self.oldPlayerLocationCicurlarRegion.contains(playerCurrentLocation.coordinate)) == false {
                AppDelegate.DisplayInfo(distance: walkingDistanceToThePaintingRounded, fromNewLocation: playerCurrentLocation)
                let gameComicBookPaintingDistanceText = " you are at \(walkingDistanceToThePaintingRounded) km from the painting"
                self.comicBookPaintnigInfoDistanceLabel.text = gameComicBookPaintingDistanceText
                self.oldPlayerLocation = playerCurrentLocation
                self.firstDistance = walkingDistanceToThePaintingRounded
                self.oldPlayerLocationCicurlarRegion = CLCircularRegion(center: self.oldPlayerLocation.coordinate, radius: 20, identifier: "geoFencingforComicsPainting")
            }else if comicsPaintingRegion.contains(playerCurrentLocation.coordinate){
                self.gameAlerContinuePicture(title: "Take a Picture", andMessage: "would you like to take a picture of the painting?")
            }
        })
    }
    
    func gameAlerContinuePicture(title: String, andMessage: String){
        self.firstDistance = 0.0
        self.numbeerOfComicBOokPaintingReached += 1
        let alertControler = UIAlertController(title: title, message: andMessage, preferredStyle: .alert)
        let takePictureAction = UIAlertAction(title : "take picture", style : .default, handler: { (action) -> Void in
            self.takeTheComicBookPainingPicutre()
        })
        
        let continueGameAction = UIAlertAction(title : "continue the game", style : .default, handler:{(action) -> Void in
            self.gameComicBookPaintingIndex += 1
            self.continueTheGame(gameComicBookPaintingIndex : self.gameComicBookPaintingIndex)
        })
        alertControler.addAction(takePictureAction)
        alertControler.addAction(continueGameAction)
        self.present(alertControler, animated : true)
    }
    
    func takeTheComicBookPainingPicutre(){
        performSegue(withIdentifier: "takePictureSegue", sender: view)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up of the different View element for the begining of the Game
        gameViewNavBar.hidesBackButton = true
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        gameComicBookPainting = listOfComicBookPaintingOfTheTour[0]
        
        setDifferentViewElementOfTheGame(gameComicBookPainting: gameComicBookPainting)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let comicBookPaintingPassed = numbeerOfComicBOokPaintingPassed
        let comicBookPaintingReached = numbeerOfComicBOokPaintingReached
        if let victorySegue = segue.destination as? VictoryViewController{
            victorySegue.numberOfComicBookPaintingPassed = comicBookPaintingPassed
            victorySegue.numberOfComicBookPaintingReached = comicBookPaintingReached
        }else if let takePictureSegue = segue.destination as? TakeaPictureViewController{
            takePictureSegue.gameComicBookPaintingIndex = gameComicBookPaintingIndex
            takePictureSegue.imageURL = gameComicBookPainting.comicsPaintingImageURL
            takePictureSegue.delegate = self
        }
        
    }
}
