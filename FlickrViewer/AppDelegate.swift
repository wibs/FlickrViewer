//
//  AppDelegate.swift
//  FlickrViewer
//
//  Created by William Grand on 3/8/19.
//  Copyright © 2019 William Grand. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        initializeWindow()
        
        return true
    }
    
    private func initializeWindow() {
            window = UIWindow(frame: UIScreen.main.bounds)
            let navController = UINavigationController()
            navController.show(SearchViewController(), sender: nil)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
    }
}

