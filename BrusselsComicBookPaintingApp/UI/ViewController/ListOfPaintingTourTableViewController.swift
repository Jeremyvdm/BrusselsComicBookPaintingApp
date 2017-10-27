//
//  ListOfPaintingTourTableViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit

class ListOfPaintingTourTableViewController: UITableViewController {
    
    // MARK: - variable declaration
    var playerComicBooksList : [ComicsBookPainting] = []
    var comicBookPaintingChosen : ComicsBookPainting?
    
    // MARK: - basic function of the table view controller
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playerComicBooksList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ListOfPaintingTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListOfPaintingTableViewCell", for: indexPath) as! ListOfPaintingTableViewCell
        
        let comicPaintings = playerComicBooksList[indexPath.row]
        cell.titleListComicPainting.text = comicPaintings.comicsPaintingTitle
        if let comicsPaintingImageURL  = comicPaintings.comicsPaintingImageURL {
            cell.comicPaintingImageView.af_setImage(withURL: comicsPaintingImageURL)
        }
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailTBVC = segue.destination as? ComicsBookPaintingDetailTableViewController, let selectedIndexPath = tableView.indexPathForSelectedRow{
            detailTBVC.comicPaintingChosen = playerComicBooksList[selectedIndexPath.row]
        }
    }
}

