//
//  ComicTourTableViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ComicTourTableViewController: UITableViewController {
    // MARK: - variable declaration
    var comicBookTourName : String = ""
    var totalDistance : Double = 0.0
    var startingLocation = CLLocation()
    var playerListOfComicBookPaintings : [ComicsBookPainting] = []
    var orderPlayerListOfComicBookPaintings : [ComicsBookPainting] = []
    var currentUser = UserApp()
    
    // MARK: - view item declaration and view item action
    @IBOutlet weak var comicTourNameTextField: UITextField!
    @IBOutlet weak var comicBookTourPaintingInfoLabel: UILabel!
    
    // MARK: - the confirm button will add the comic book tour to the user database in firebase
    @IBAction func confirmButton(_ sender: Any) {
        guard let tourName = comicTourNameTextField.text
            else{return}
        comicBookTourName = tourName
        var listOfComicBookPainting : [String] = []
        for comicBookPainting in playerListOfComicBookPaintings{
            listOfComicBookPainting.append(comicBookPainting.comicsPaintingTitle)
        }
        let playerComicBookPaintingsTour = ComicBooksPaintingsTour(comicBookTOurName: tourName, listOfComicBookPaintingsTitle: listOfComicBookPainting)
        let playerNumberOfComicBookPaintingTour = currentUser.listOfComicBookPaintingsTours.count
        FirebaseController.sharedInstance.addComicBookPaintingsTourToUser(playerNumberOfComicBookPaintingTour : playerNumberOfComicBookPaintingTour, comicBooksPaintingsTour: playerComicBookPaintingsTour)
    }
    
    // will convert the comic book painting in location service controller for the next function that is using location service controller instead of ComicBookPainting
    func convertListOfComicBookPaintingInListOfLocationController(listOfComicBookPaintings : [ComicsBookPainting]) -> [LocationServiceController]{
        var listOfLocationControllerForComicBookPaintings : [LocationServiceController] = []
        for comicBookPainting in listOfComicBookPaintings{
            let LocationControllerForComicBookPainting = LocationServiceController(name: comicBookPainting.comicsPaintingTitle, latitude: comicBookPainting.lat, longitude: comicBookPainting.lng)
            listOfLocationControllerForComicBookPaintings.append(LocationControllerForComicBookPainting)
        }
        return listOfLocationControllerForComicBookPaintings
    }
    
    // Will order the different location service controller for the comic book painting by the distanse
    func orderTheComicBookPaintingByDistance(fromStartPoint startPoint: CLLocationCoordinate2D, betweenComicBookPaintingLocation comicBookPaintnigsLocations: [LocationServiceController], limitTo limit: Int, course: [LocationServiceController]) -> [LocationServiceController]{
        
        guard !comicBookPaintnigsLocations.isEmpty,   course.count < limit else {
            return course
        }
        let startPointLocation = CLLocation(latitude: startPoint.latitude, longitude: startPoint.longitude)
        var nearestPlace: LocationServiceController = comicBookPaintnigsLocations.first!
        var nearestDistance: CLLocationDistance = nearestPlace.location.distance(from: startPointLocation)
        var nearestIndex = 0
        for (index, place) in comicBookPaintnigsLocations.enumerated(){
            let distance = place.location.distance(from: startPointLocation)
            if distance < nearestDistance{
                nearestPlace = place
                nearestDistance = distance
                nearestIndex = index
            }
        }
        var copycomicBookPaintnigsLocations = comicBookPaintnigsLocations
        copycomicBookPaintnigsLocations.remove(at: nearestIndex)
        var currentCourse = course
        currentCourse.append(nearestPlace)
        
        return self.orderTheComicBookPaintingByDistance(fromStartPoint:nearestPlace.coordinate, betweenComicBookPaintingLocation: copycomicBookPaintnigsLocations, limitTo: limit, course: currentCourse)
    }
    
    // will concvert the list of location service controller into a list Comic Book Panitng
    
    func orderThePlayerListOfComicBookPaintings(listOfComicBookPaintingsLocationServiceController : [LocationServiceController], listOfComicBookPaintings : [ComicsBookPainting]) -> [ComicsBookPainting]{
        var orderLsitOfComicBookPainting : [ComicsBookPainting] = []
        for comicBookpaintingLocationserviceController in listOfComicBookPaintingsLocationServiceController{
            for comicBookPainting in listOfComicBookPaintings{
                if comicBookPainting.comicsPaintingTitle == comicBookpaintingLocationserviceController.name{
                    orderLsitOfComicBookPainting.append(comicBookPainting)
                }
            }
        }
        return orderLsitOfComicBookPainting
    }
    
    
    // will make a list of the comicBookPainting location
    func obtainTheListOfComicBookPaintingLocation (listOfComicBookPaintings : [ComicsBookPainting])-> [CLLocation]{
        var listOfComicBookPaintingLocation: [CLLocation] = []
        for comicBookPainting in listOfComicBookPaintings{
            let comicBookPaintingLocation = CLLocation(latitude: comicBookPainting.lat, longitude: comicBookPainting.lng)
            listOfComicBookPaintingLocation.append(comicBookPaintingLocation)
        }
        return listOfComicBookPaintingLocation
    }
    
    private func createTheTextForDistanceLabel(listOfComicBookPaintingLocation : [CLLocation]){
        var comicBookPaintingLocationA = listOfComicBookPaintingLocation[0]
        var totalTourDistance : Double = 0.00
        var count = 0
        for comicBookPaintingLocationB in listOfComicBookPaintingLocation[1...listOfComicBookPaintingLocation.count-1]{
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: comicBookPaintingLocationA.coordinate))
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: comicBookPaintingLocationB.coordinate))
            directionRequest.transportType = .walking
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: { (response, error) in
                guard let route = response?.routes.first else{return}
                totalTourDistance += route.distance
                count += 1
                if(count == self.playerListOfComicBookPaintings.count - 1){
                    let totalDistanceDiv1000 = totalTourDistance/1000
                    let totalDistanceToDisplay = (totalDistanceDiv1000*100).rounded()/100
                    self.comicBookTourPaintingInfoLabel.text = "The comicbook Painting tour has \(self.playerListOfComicBookPaintings.count) Painting and the total distance of the tour is \(totalDistanceToDisplay) km."
                }
            })
            
            comicBookPaintingLocationA = comicBookPaintingLocationB
            
                
        }
    }
    
    
    
    // will create the list of the comic book painting that will be order by distance and calculate the total distance of the tour
    func orderTheListOfComicBookPaintings(){
        let startPointLocation = CLLocationCoordinate2D(latitude: startingLocation.coordinate.latitude, longitude: startingLocation.coordinate.longitude)
        let limit = playerListOfComicBookPaintings.count
        let listOfComicBookPaintingLocationServiceController = convertListOfComicBookPaintingInListOfLocationController(listOfComicBookPaintings: playerListOfComicBookPaintings)
        let orderListOfComicBookPaintingLocationServiceController = orderTheComicBookPaintingByDistance(fromStartPoint: startPointLocation, betweenComicBookPaintingLocation: listOfComicBookPaintingLocationServiceController, limitTo: limit, course: [])
        orderPlayerListOfComicBookPaintings = orderThePlayerListOfComicBookPaintings(listOfComicBookPaintingsLocationServiceController: orderListOfComicBookPaintingLocationServiceController, listOfComicBookPaintings: playerListOfComicBookPaintings)
        let listOfComicBookPaintingLocation = obtainTheListOfComicBookPaintingLocation(listOfComicBookPaintings: orderPlayerListOfComicBookPaintings)
        createTheTextForDistanceLabel(listOfComicBookPaintingLocation: listOfComicBookPaintingLocation)
    }
    
    // MARK: - basic function of the view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        orderTheListOfComicBookPaintings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let comicPaintingMapSegue = segue.destination as? ComicBookPaintingTourMapViewController{
            comicPaintingMapSegue.listOfComicBookPaintings = self.orderPlayerListOfComicBookPaintings
            comicPaintingMapSegue.startingPointLocation = startingLocation
        }
        else if let listOfPaintingController = segue.destination as? ListOfPaintingTourTableViewController{
            listOfPaintingController.playerComicBooksList = self.orderPlayerListOfComicBookPaintings
        }
        else if let gameComicBookPaintingVC = segue.destination as? GameViewController{
            gameComicBookPaintingVC.listOfComicBookPaintingOfTheTour = self.orderPlayerListOfComicBookPaintings
        }
    }
    
}

