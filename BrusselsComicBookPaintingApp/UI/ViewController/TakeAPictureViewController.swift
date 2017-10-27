//
//  TakeAPictureViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit

class TakeAPictureViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    var delegate : TakeAPictureViewControllerDelegate?
    var gameComicBookPaintingIndex : Int = 0
    
    @IBOutlet weak var ComicBookPaintingPictureImagePickerView: UIImageView!
    
    @IBAction func takeAPicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = self.delegate {
            gameComicBookPaintingIndex += 1
            delegate.nextComicBookPaintng(gameComicBookPaintingIndex : gameComicBookPaintingIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

protocol TakeAPictureViewControllerDelegate {
    func nextComicBookPaintng(gameComicBookPaintingIndex : Int);
}

