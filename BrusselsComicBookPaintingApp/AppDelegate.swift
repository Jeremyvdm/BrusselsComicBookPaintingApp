//
//  AppDelegate.swift
//  BrusselsComicBookPaintingApp
//
//  Created by Jeremy Vandermeersch on 27/10/2017.
//  Copyright © 2017 Jeremy Vandermeersch. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import CoreLocation
import UserNotifications

extension Notification.Name {
    static let onUserPositionChanged = Notification.Name("be.underside.MapPoint.onUserPositionChanged")
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var lastSavedLocation: CLLocation?{
        didSet{
            guard let location : CLLocation = lastSavedLocation else{return}
            
            NotificationCenter.default.post(name: .onUserPositionChanged , object: nil, userInfo: ["lastLocation" : location])
        }
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //initialise the application with the configuration of firebase
        //Location services
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        // User Notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        let unique = UUID().uuidString
        
        FirebaseApp.configure()
        
        return true
    }
    
    
    static func sendLocalUserNotification(withTitle title: String, Message msg: String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = msg
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: title, content: content, trigger: nil))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    static func DisplayInfo(distance : Double, fromNewLocation newLocation: CLLocation){
        let place = LocationServiceController(name: "User Location Update", latitude:newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        place.fetchPlacemark { (success, error) in
            if let placemark = place.placemark{
                sendLocalUserNotification(withTitle: "your position has change", Message: "You are now at \(distance) from the ComicBookPainting")
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else {return}
        
        if lastSavedLocation == nil{
            self.lastSavedLocation = newLocation
        }else{
            if newLocation.horizontalAccuracy < locationManager.desiredAccuracy && newLocation.distance(from: lastSavedLocation!) > 100{
                self.lastSavedLocation = newLocation
            }
        }
        
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

