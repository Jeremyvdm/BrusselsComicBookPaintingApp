//
//  FirebaseController.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON

class FirebaseController {
    
    static let sharedInstance = FirebaseController()
    var currentUser: User?
    var databaseRef = Database.database().reference()
    
    func logInToApplication(userName : String, password : String, completionHandler : @escaping (Bool, Error?)->Void){
        Auth.auth().signIn(withEmail: userName, password: password) { (user, error) in
            self.currentUser = user
            completionHandler(user != nil, error)
        }
    }
    
    func createANewUser(userName : String, password : String, completionHandler : @escaping (Bool, Error?)->   Void){
        Auth.auth().createUser(withEmail: userName, password: password){(user,error) in
            if let error = error{
                completionHandler(user == nil, error)
            }
            else{
                
                self.currentUser = user
                self.currentUser?.sendEmailVerification(completion: nil)
                completionHandler(user != nil, error)
            }
        }
    }
    
    
    
    func logOutFromTheApplicatio(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func createUserAppAndStoreApp( email: String, lastName: String, firstName : String, address : String){
        let user = UserApp(email: email, firstName: firstName, lastName: lastName, address: address)
        storeIntDb(userApp: user)
    }
    
    func storeIntDb(userApp : UserApp){
        let usersRefTable = databaseRef.child("userApp")
        storeUserAppInformation(usersRefTable: usersRefTable, userApp : userApp)
    }
    
    func storeUserAppInformation(usersRefTable: DatabaseReference, userApp : UserApp){
        let user = (FirebaseController.sharedInstance.currentUser)!
        usersRefTable.child(user.uid).child("email").setValue(userApp.email)
        usersRefTable.child(user.uid).child("lastName").setValue(userApp.lastName)
        usersRefTable.child(user.uid).child("firstName").setValue(userApp.firstName)
        usersRefTable.child(user.uid).child("address").setValue(userApp.address)
        
    }
    
    func getUserFromDataBase(handler: @escaping (UserApp) -> Void){
        let usersRefTable = databaseRef.child("userApp")
        let userRefTable = usersRefTable.child((FirebaseController.sharedInstance.currentUser?.uid)!)
        
        userRefTable.observeSingleEvent(of:.value, with: { (snapshot) in
            if let value = snapshot.value
            {
                let userJson = JSON(value)
                guard let userLastName = userJson["lastName"].string,
                    let userEmail = userJson["email"].string,
                    let userFistName = userJson["firstName"].string,
                    let userAddress = userJson["address"].string else {return}
                let listOfCOmicBookPaintingsToursJson  = userJson["comicBookPaintingsTour"]
                let listOfComicBookPaintingsTours = self.getListComicBookPaintingsTourFromBasicJSon(listOfComicsPaintingsToursJsonArray: listOfCOmicBookPaintingsToursJson)
                let userApp = UserApp(email: userEmail, firstName: userFistName, lastName: userLastName, address: userAddress, listOfComicBookPaintingsTours : listOfComicBookPaintingsTours)
                handler(userApp)
            }
        })
    }
    
    func getListComicBookPaintingsTourFromBasicJSon(listOfComicsPaintingsToursJsonArray : JSON) -> [ComicBooksPaintingsTour]{
        var listOfComicBookPaintingsTour : [ComicBooksPaintingsTour] = []
        let numberOfComicBookPaintingsTour = listOfComicsPaintingsToursJsonArray.count
        for i in 0 ..< numberOfComicBookPaintingsTour{
            let comicBookPaintingTourJson : JSON = listOfComicsPaintingsToursJsonArray[i]
            let comicBookPaintingTour  : ComicBooksPaintingsTour = getComicBookPaintingsTourFromJson(comicBookPaintingTourJson : comicBookPaintingTourJson)
            listOfComicBookPaintingsTour.append(comicBookPaintingTour)
        }
        return listOfComicBookPaintingsTour
    }
    
    
    func getComicBookPaintingsTourFromJson(comicBookPaintingTourJson : JSON) -> ComicBooksPaintingsTour{
        var comicBookPaintingsTour : ComicBooksPaintingsTour = ComicBooksPaintingsTour()
        guard let comicBookPaintingsTourName = comicBookPaintingTourJson["comicBookPaintingsTourName"].string else{
            return ComicBooksPaintingsTour()}
        var listOfComicBookPaintingTitle : [String] = []
        for value in comicBookPaintingTourJson["listOfComicBookPaintingsTitle"].arrayValue{
            listOfComicBookPaintingTitle.append(value.stringValue)
        }
        comicBookPaintingsTour.comicBooksPaintingsTourName = comicBookPaintingsTourName
        comicBookPaintingsTour.listOfComicBookPaintingsTitle = listOfComicBookPaintingTitle
        return comicBookPaintingsTour
    }
    
    
    func addComicBookPaintingsTourToUser(playerNumberOfComicBookPaintingTour : Int, comicBooksPaintingsTour : ComicBooksPaintingsTour){
        if let firebaseUser = FirebaseController.sharedInstance.currentUser{
            let userRefTable = databaseRef.child("userApp")
            let userUidRef = userRefTable.child(firebaseUser.uid)
            let comicBookPaintingsTourArrayRef = userUidRef.child("comicBookPaintingsTour")
            let comicBookPaintnigsTourElement = comicBookPaintingsTourArrayRef.child(String(playerNumberOfComicBookPaintingTour))
            comicBookPaintnigsTourElement.child("comicBookPaintingsTourName").setValue(comicBooksPaintingsTour.comicBooksPaintingsTourName)
            let listOfComicBookPaintingsTitleRef = comicBookPaintnigsTourElement.child("listOfComicBookPaintingsTitle")
            let listOfComicBookPaintingsTitle = comicBooksPaintingsTour.listOfComicBookPaintingsTitle
            for i in 0 ..< listOfComicBookPaintingsTitle.count{
                let title = listOfComicBookPaintingsTitle[i]
                listOfComicBookPaintingsTitleRef.child(String(i)).setValue(title)
            }
            
        }
    }
}

