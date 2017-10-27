//
//  UserApp.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit

class UserApp {
    var email : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var address : String = ""
    var listOfComicBookPaintingsTours : [ComicBooksPaintingsTour] = []
    
    init()
    {}
    
    init(email : String, firstName : String, lastName : String, address : String){
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
    }
    
    init(email : String, firstName : String, lastName : String, address : String, listOfComicBookPaintingsTours : [ComicBooksPaintingsTour]){
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.listOfComicBookPaintingsTours  = listOfComicBookPaintingsTours
    }
    
}


