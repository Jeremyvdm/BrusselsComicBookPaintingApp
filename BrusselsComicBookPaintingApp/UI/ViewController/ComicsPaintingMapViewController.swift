//
//  ComicsPaintingMapViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import MapKit

class ComicsPaintingMapViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    // MARK: - vairable declaration
    let locationManager = CLLocationManager()
    var comicBookPaintings : [ComicsBookPainting] = []
    var comicBook: ComicsBookPainting?
    
    // MARK: - view item declaration
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - custom function
    // initial of the search to fetch all the comics books painting to display them on the map
    func addComicsBookPaintingPin(comicBookPaintings : [ComicsBookPainting]){
        for comicBookPainting in comicBookPaintings{
            let pin = MKPointAnnotation()
            let location = CLLocationCoordinate2D(latitude: comicBookPainting.lat, longitude: comicBookPainting.lng)
            pin.coordinate = location
            pin.title = comicBookPainting.comicsPaintingTitle
            mapView.addAnnotation(pin)
        }
        let allAnnotation = mapView.annotations
        mapView.showAnnotations(allAnnotation, animated: true)
    }
    
    // MARK: - map view function
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
    
    // will define what happen when a pin is selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            print("you Selected \(String(describing: annotation.title))")
            for comicsPainting in comicBookPaintings{
                guard let title = annotation.title else{return}
                if comicsPainting.comicsPaintingTitle == title{
                    comicBook  = comicsPainting
                }
            }
        }
        performSegue(withIdentifier: "comicPaintingDetailSegue", sender: view)
    }
    
    // MARK: - function of the view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self as CLLocationManagerDelegate
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self as MKMapViewDelegate
        addComicsBookPaintingPin(comicBookPaintings: comicBookPaintings)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailTBVC = segue.destination as? ComicsBookPaintingDetailTableViewController{
            detailTBVC.comicPaintingChosen = comicBook
        }
    }
    
}
