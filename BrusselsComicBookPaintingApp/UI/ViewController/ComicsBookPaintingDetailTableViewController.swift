//
//  ComicsBookPaintingDetailTableViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreLocation

class ComicsBookPaintingDetailTableViewController: UITableViewController {
    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var tabBarDetailTitle: UINavigationItem!
    @IBOutlet weak var adressLabel: UILabel!
    
    var comicPaintingChosen : ComicsBookPainting?{
        didSet{
            loadViewIfNeeded()
            displayComicDetail()
            
        }
    }
    
    // MARK: - custom function
    
    // will define what the different view item will display
    func displayComicDetail(){
        guard let comicPaintingChosen = comicPaintingChosen
            else{return}
        tabBarDetailTitle.title = comicPaintingChosen.comicsPaintingTitle
        authorLabel.text = comicPaintingChosen.comicsPaintingAuthor
        guard let year = String(comicPaintingChosen.comicsPaintingYear) as? String else {return}
        yearLabel.text = year
        guard let comicsPaintingImageURL = comicPaintingChosen.comicsPaintingImageURL else{return}
        comicImageView.af_setImage(withURL: comicsPaintingImageURL)
        let locationServiceController = LocationServiceController(name: comicPaintingChosen.comicsPaintingTitle, latitude: comicPaintingChosen.lat, longitude: comicPaintingChosen.lng)
        locationServiceController.fetchPlacemark(){(success, error) -> Void in
            guard let address : String = locationServiceController.formatedAddress else
            {
                self.presentAlertDialog(withError: error!)
                return
            }
            self.adressLabel.text = address
        }
    }
    
    
    // MARK: - basic view controller function
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




