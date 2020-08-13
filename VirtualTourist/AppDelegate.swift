//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Nadyah Abdulrahman on 22/12/1441 AH.
//  Copyright © 1441 Sarah Alhabib. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let dataController = DataController(modelName: "VirtualTourist")
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        mapViewController.dataController = dataController
        
        return true
    }

    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    func saveViewContext() {
         try? dataController.viewContext.save()
    }


}

