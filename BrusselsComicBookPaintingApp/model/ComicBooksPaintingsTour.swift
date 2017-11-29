//
//  ComicBooksPaintingsTour.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import Foundation

struct ComicBooksPaintingsTour {
    var dbId : String = ""
    var comicBooksPaintingsTourName : String = ""
    var listOfComicBookPaintingsTitle : [String] = []
    init(){}
    init(comicBookTOurName : String, listOfComicBookPaintingsTitle : [String], dbId : String){
        self.comicBooksPaintingsTourName = comicBookTOurName
        self.listOfComicBookPaintingsTitle = listOfComicBookPaintingsTitle
        self.dbId = dbId
    }
    
    init(comicBookTOurName : String, listOfComicBookPaintingsTitle : [String]){
        self.comicBooksPaintingsTourName = comicBookTOurName
        self.listOfComicBookPaintingsTitle = listOfComicBookPaintingsTitle
    }
}
