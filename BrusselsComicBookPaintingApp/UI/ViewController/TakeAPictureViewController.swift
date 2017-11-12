//
//  TakeAPictureViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import AlamofireImage

class TakeAPictureViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    var delegate : TakeAPictureViewControllerDelegate?
    var gameComicBookPaintingIndex : Int = 0
    var imageURL : URL?
    
    @IBOutlet weak var ComicBookPaintingPictureImagePickerView: UIImageView!
    
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
        guard let comicsPaintingImageURL = imageURL else{return}
        ComicBookPaintingPictureImagePickerView.af_setImage(withURL: comicsPaintingImageURL)
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

