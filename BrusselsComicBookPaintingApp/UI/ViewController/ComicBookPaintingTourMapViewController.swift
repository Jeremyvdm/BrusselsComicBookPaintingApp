//
//  ComicBookPaintingTourMapViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import MapKit

class ComicBookPaintingTourMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    // MARK: - variable declaration
    let locationManager = CLLocationManager()
    var listOfComicBookPaintings : [ComicsBookPainting] = []
    var comicBook: ComicsBookPainting?
    var startingPointLocation : CLLocation = CLLocation()
    
    // MARK: - view item declaration
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tourMapNavBar: UINavigationItem!
    
    
    // MARK: - custom function section
    
    // this function will draw the map and the map annotation
    private func finishDrawingMap(){
        addComicsBookPaintingPin()
        let listOfLocationServiceControllerForComicBookPainting = convertListOfComicBookPaintingInListOfLocationController(listOfComicBookPaintings: listOfComicBookPaintings )
        let listOfComicBookPaintingLocation = convertToListOfComicBookPaintingLocation(listOfLocationServiceControllerForComicBookPainting : listOfLocationServiceControllerForComicBookPainting)
        if listOfComicBookPaintingLocation.count == listOfComicBookPaintings.count{
            drawPathBetweenComicBookPaintingLocation(listOfComicBookPaintingLocation : listOfComicBookPaintingLocation)
            mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    // will obtain the list of comic book painting location
    func convertToListOfComicBookPaintingLocation(listOfLocationServiceControllerForComicBookPainting : [LocationServiceController]) -> [CLLocation]{
        var listOfComicBookPaintingLocation : [CLLocation] = []
        for locationServiceControlerForComicBookPainting in listOfLocationServiceControllerForComicBookPainting{
            listOfComicBookPaintingLocation.append(locationServiceControlerForComicBookPainting.location)
        }
        return listOfComicBookPaintingLocation
    }
    
    // will convert the comicBook painting location in location service controller so it will be easier to obtain dwaw the path between the painting
    func convertListOfComicBookPaintingInListOfLocationController(listOfComicBookPaintings : [ComicsBookPainting]) -> [LocationServiceController]{
        var listOfLocationControllerForComicBookPaintings : [LocationServiceController] = []
        for comicBookPainting in listOfComicBookPaintings{
            let LocationControllerForComicBookPainting = LocationServiceController(name: comicBookPainting.comicsPaintingTitle, latitude: comicBookPainting.lat, longitude: comicBookPainting.lng)
            listOfLocationControllerForComicBookPaintings.append(LocationControllerForComicBookPainting)
        }
        return listOfLocationControllerForComicBookPaintings
    }
    
    
    // MARK: - map view function
    // initial of the search to fetch all the comics books painting to display them on the map
    func addComicsBookPaintingPin(){
        for comicBookPainting in listOfComicBookPaintings{
            let pin = MKPointAnnotation()
            let location = CLLocationCoordinate2D(latitude: comicBookPainting.lat, longitude: comicBookPainting.lng)
            pin.coordinate = location
            pin.title = comicBookPainting.comicsPaintingTitle
            mapView.addAnnotation(pin)
        }
        let allAnnotation = mapView.annotations
        mapView.showAnnotations(allAnnotation, animated: true)
    }
    
    // function to obtain the user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first{
            print(currentLocation.coordinate)
        }
    }
    
    // will draw the pin in the map view
    func mapView(_ mapView : MKMapView, viewFor annotation : MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation{
            return nil
        }else{
            let pinId = "myPin"
            var pinView : MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView{
                dequeuedView.annotation = annotation
                pinView = MKPinAnnotationView(annotation : annotation, reuseIdentifier : pinId)
            }else{
                pinView = MKPinAnnotationView(annotation : annotation, reuseIdentifier : pinId)
            }
            return pinView
        }
    }
    
    // will draw the path between the different pin
    private func drawPathBetweenComicBookPaintingLocation(listOfComicBookPaintingLocation : [CLLocation]){
        var comicBookPaintingLocationA = listOfComicBookPaintingLocation[0]
        for comicBookPaintingLocationB in listOfComicBookPaintingLocation[1...listOfComicBookPaintingLocation.count-1]{
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: comicBookPaintingLocationA.coordinate))
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: comicBookPaintingLocationB.coordinate))
            directionRequest.transportType = .walking
            let directions = MKDirections(request: directionRequest)
            directions.calculate(completionHandler: { (response, error) in
                guard let route = response?.routes.first else{return}
                self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
            })
            comicBookPaintingLocationA = comicBookPaintingLocationB
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polylineOverlay = overlay as? MKPolyline{
            let renderer = MKPolylineRenderer(overlay: polylineOverlay)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 4.0
            return renderer
        }else{
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            for comicsPainting in listOfComicBookPaintings{
                guard let title = annotation.title else{return}
                if comicsPainting.comicsPaintingTitle == title{
                    comicBook  = comicsPainting
                }
            }
        }
        performSegue(withIdentifier: "detailSegueFromTourMap", sender: view)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self as CLLocationManagerDelegate
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self as MKMapViewDelegate
        mapView.showsUserLocation = true
        finishDrawingMap()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.navigationItem.hidesBackButton = true
        parent?.navigationItem.title = "Comics Painting Tour Map"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let detailTBVC = segue.destination as? ComicsBookPaintingDetailTableViewController{
            detailTBVC.comicPaintingChosen = comicBook
        }
    }
    
}

