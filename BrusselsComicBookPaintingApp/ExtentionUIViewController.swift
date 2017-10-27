//
//  ExtentionUIViewController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func presentAlertDialog(withError error : Error){
        self.presentEventDialog(withTitle :"An Error has Occured!", andMessage : error.localizedDescription,actionEnum: .cancelAction)
    }
    func presentEventDialog(withTitle: String, andMessage : String, actionEnum : action){
        let alertControler = UIAlertController(title: title, message: andMessage, preferredStyle: .alert)
        let action : UIAlertAction?
        switch actionEnum {
        case .cancelAction:
            action = UIAlertAction(title : "OK", style : .cancel)
        case .continueAction:
            action = UIAlertAction(title : "OK", style : .default)
        }
        guard let actionsend = action else{return}
        alertControler.addAction(actionsend)
        self.present(alertControler, animated : true)
    }
    enum action{
        case cancelAction
        case continueAction
    }
}

