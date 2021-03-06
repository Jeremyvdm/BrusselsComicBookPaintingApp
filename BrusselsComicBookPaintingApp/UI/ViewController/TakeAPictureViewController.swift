//
//  TakeAPictureViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import AlamofireImage

protocol TakeAPictureViewControllerDelegate {
    func passToNextPanitng(comicsPaintingIndex : Int)
}

class TakeaPictureViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    
    let imagePicker = UIImagePickerController()
    var delegate : TakeAPictureViewControllerDelegate?
    var gameComicBookPaintingIndex : Int = 0
    var imageURL : URL?
    
    @IBOutlet weak var ComicBookPaintingPictureImagePickerView: UIImageView!
    
    @IBOutlet weak var pictureNavBar: UINavigationItem!
    @IBAction func takeAPicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func savePictureAction(_ sender: Any) {
        let imageData = UIImageJPEGRepresentation (ComicBookPaintingPictureImagePickerView.image!, 0.6)
        let compressImage = UIImage(data : imageData!)
        UIImageWriteToSavedPhotosAlbum(compressImage!, nil, nil, nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            ComicBookPaintingPictureImagePickerView.image = image
            ComicBookPaintingPictureImagePickerView.contentMode = .scaleAspectFit
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super .didMove(toParentViewController: parent)
        if (parent as? GameViewController) != nil{
            delegate?.passToNextPanitng(comicsPaintingIndex: gameComicBookPaintingIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pictureNavBar.title = "Picture Time"
        imagePicker.delegate = self
        guard let comicsPaintingImageURL = imageURL else{return}
        ComicBookPaintingPictureImagePickerView.af_setImage(withURL: comicsPaintingImageURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


