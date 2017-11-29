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
    var selectedComicsPainting: ComicsBookPainting?
    var customPlayerComicBookPaintingTour : [ComicsBookPainting] = []
    var currentUser : UserApp = UserApp()
    
    // MARK: - view item declaration
    
    @IBOutlet weak var completeMatNavBar: UINavigationItem!
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
        let pinId = "myPin"
        var pinView : MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView{
            dequeuedView.annotation = annotation
            pinView = dequeuedView
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = UIButton(type : .detailDisclosure)
            pinView.leftCalloutAccessoryView = UIButton(type: .contactAdd)
        }else{
            pinView = MKPinAnnotationView(annotation : annotation, reuseIdentifier : pinId)
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = UIButton(type : .detailDisclosure)
            pinView.leftCalloutAccessoryView = UIButton(type: .contactAdd)
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            guard let selectedAnnotation = view.annotation
                else{return}
            for comicsPainting in comicBookPaintings{
                guard let title = selectedAnnotation.title else{return}
                if comicsPainting.comicsPaintingTitle == title{
                    selectedComicsPainting  = comicsPainting
                }
            }
            performSegue(withIdentifier: "detailSegueFromCompleteMap", sender: view)
        }
        if control == view.leftCalloutAccessoryView{
            guard let selectedAnnotation = view.annotation
                else{return}
            for comicsPainting in comicBookPaintings{
                guard let title = selectedAnnotation.title else{return}
                if comicsPainting.comicsPaintingTitle == title{
                    selectedComicsPainting  = comicsPainting
                    let toastMessage = "\(title) Painting has just been added to your custom Comics painting tour"
                    showToast(message: toastMessage)
                }
            }
            customPlayerComicBookPaintingTour.append(selectedComicsPainting!)
        }
    }
   
    @objc func goToComicBookTourAction(_ sender : UIBarButtonItem){
        if customPlayerComicBookPaintingTour.count > 0{
            performSegue(withIdentifier: "goToTourSegue", sender: sender)
        }else{
            let alertControler = UIAlertController(title: "no Comics Painting chosen", message: "to continue you need to choose at least 1 comics Painting", preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "continue", style: .cancel, handler: nil)
            alertControler.addAction(continueAction)
            self.present(alertControler, animated : true)
        }
    }
    
    // MARK: - function of the view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        locationManager.delegate = self as CLLocationManagerDelegate
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self as MKMapViewDelegate
        addComicsBookPaintingPin(comicBookPaintings: comicBookPaintings)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationItem.hidesBackButton = true
        self.parent?.navigationItem.title = "Comics Painting Complete Map"
        let rightBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ComicsPaintingMapViewController.goToComicBookTourAction(_:)))
        self.parent?.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.parent?.navigationItem.rightBarButtonItem = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPlayerComicBookTour() -> [ComicsBookPainting]{
        var playerCustomComisPaintingTour : [ComicsBookPainting] = []
        for comicsPainting in customPlayerComicBookPaintingTour{
            playerCustomComisPaintingTour.append(comicsPainting)
        }
        return playerCustomComisPaintingTour
    }
    
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailTBVC = segue.destination as? ComicsBookPaintingDetailTableViewController{
            detailTBVC.comicPaintingChosen = selectedComicsPainting
        }
        if let comicBookPaintingTourTabVC = segue.destination as? ComicBookPaintingTourTabBarController{
            comicBookPaintingTourTabVC.playerListOfComicBookPaintings = fetchPlayerComicBookTour()
            comicBookPaintingTourTabVC.currentUser = currentUser
        }
    }
    
}
