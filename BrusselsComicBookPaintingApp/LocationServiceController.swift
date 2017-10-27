//
//  LocationServiceController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import Foundation
import CoreLocation

class LocationServiceController {
    var name : String
    var coordinate : CLLocationCoordinate2D{
        didSet{
            placemark = nil
        }
    }
    
    private(set) var placemark: CLPlacemark?
    var location: CLLocation{
        return CLLocation(latitude : self.coordinate.latitude, longitude : self.coordinate.longitude)
    }
    
    var formatedAddress: String?{
        if let placemark = placemark{
            return "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "") \n \(placemark.subLocality ?? "") \n \(placemark.locality ?? "")"
        }else{
            return nil
        }
    }
    
    init(name : String, latitude : Double, longitude : Double){
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func fetchPlacemark(completionHandler: @escaping (Bool, Error?) -> Void){
        CLGeocoder().reverseGeocodeLocation(self.location){ (placemarks, error) in
            self.placemark = placemarks?.first
            completionHandler(self.placemark != nil, error)
        }
    }
}


