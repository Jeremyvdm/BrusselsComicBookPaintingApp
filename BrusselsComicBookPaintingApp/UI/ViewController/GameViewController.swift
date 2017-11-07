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
    
    var currentPlayerLocation: CLLocation?{
        didSet{
            playTheGameAndGetTheDisanceTF(playerCurrentLocation: self.currentPlayerLocation!, gameComicBookPainting: gameComicBookPainting)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentPlayerLocation = (UIApplication.shared.delegate as! AppDelegate).lastSavedLocation
        
        NotificationCenter.default.addObserver(forName: .onUserPositionChanged, object: nil, queue: OperationQueue.main) { (notification) in
            if let newLocation = notification.userInfo?["lastLocation"] as? CLLocation{
                self.currentPlayerLocation = newLocation
            }
        }
    }
    
    
    
    
    
    @IBOutlet weak var gameNavigationTitle: UINavigationItem!
    @IBOutlet weak var comicBookPaintingImageView: UIImageView!
    @IBOutlet weak var comicBookPaintingInfoAdressLabel: UILabel!
    @IBOutlet weak var comicBookPaintnigInfoDistanceLabel: UILabel!
    
    @IBAction func goTheNextComicBookPainting(_ sender: Any) {
        gameComicBookPaintingIndex += 1
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
    
    func nextComicBookPaintng(gameComicBookPaintingIndex: Int) {
        self.gameComicBookPaintingIndex = gameComicBookPaintingIndex
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
        
        gameNavigationTitle.title! = gameComcBookPaintingTitle
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
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: playerCurrentLocation.coordinate))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: gameComicBookPaintingLocation.coordinate))
        directionRequest.transportType = .walking
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: { (response, error) in
            guard let route = response?.routes.first else{return}
            walkingDistanceToThePainting = route.distance
            
            let walkingDistanceToThePaintingDiv1000 = walkingDistanceToThePainting/1000
            let walkingDistanceToThePaintingRounded = (walkingDistanceToThePaintingDiv1000*100).rounded()/100
            AppDelegate.DisplayInfo(distance: walkingDistanceToThePaintingRounded, fromNewLocation: playerCurrentLocation)
            
            let gameComicBookPaintingDistanceText = " you are at \(walkingDistanceToThePaintingRounded) km from the painting"
            self.comicBookPaintnigInfoDistanceLabel.text = gameComicBookPaintingDistanceText
            
            if walkingDistanceToThePaintingRounded < 0.06{
                self.gameAlerContinuePicture(title: "Take a Picture", andMessage: "would you like to take a picture of the painting?")
            }
        })
        
    }
    
    func gameAlerContinuePicture(title: String, andMessage: String){
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
}
