//
//  WebServiceControler.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


class WebServiceControler: NSObject {
    static func fetchComicsBookPainting( handler : @escaping ([ComicsBookPainting]) -> Void){
        let comicsPaintingBaseURL = URL(string : "https://opendata.bruxelles.be/api/v2/catalog/datasets/bruxelles_parcours_bd/records?start=0&rows=52")!
        let task = URLSession.shared.dataTask(with: comicsPaintingBaseURL){
            (data,response,error) in
            if let data = data{
                let json = JSON(data : data)
                let results = json["records"].arrayValue
                let comicPainting = results.flatMap{ComicsBookPainting(json: $0)}
                DispatchQueue.main.async {
                    handler(comicPainting)
                }
            }
        }
        task.resume()
    }
}

