//
//  ComicsBookPainting.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import RealmSwift

class ComicsBookPainting : Object {
    @objc dynamic var comicsPaintingTitle : String = ""
    @objc dynamic var comicsPaintingAuthor : String = ""
    @objc dynamic var comicsPaintingYear : Int = 0
    @objc dynamic var lat: Double = 0.0
    @objc dynamic var lng: Double = 0.0
    
    
    @objc dynamic private var imageAdressesStr : String = ""
    
    var comicsPaintingImageURL : URL?{
        return URL(string: imageAdressesStr)
    }
    
    convenience init?(json  : JSON){
        self.init()
        guard let title = json["record"]["fields"]["personnage_s"].string,
            let author = json["record"]["fields"]["auteur_s"].string,
            let year = json["record"]["fields"]["annee"].string,
            let imageUrl = json["record"]["fields"]["photo"]["url"].string,
            let lat = json["record"]["fields"]["coordonnees_geographiques"]["lat"].double,
            let lng = json["record"]["fields"]["coordonnees_geographiques"]["lon"].double else{return}
        
        self.comicsPaintingTitle = title
        self.comicsPaintingAuthor = author
        if let year : Int = Int(year){
            self.comicsPaintingYear = year
        }
        self.lat = lat
        self.lng = lng
        self.imageAdressesStr = imageUrl
    }
}
