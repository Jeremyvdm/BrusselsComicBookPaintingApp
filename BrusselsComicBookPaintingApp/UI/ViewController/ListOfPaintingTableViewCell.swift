//
//  ListOfPaintingTableViewCell.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit

class ListOfPaintingTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var comicPaintingImageView: UIImageView!
    @IBOutlet weak var titleListComicPainting: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

