//
//  AppDelegate.swift
//  Patient Records
//
//  Created by Patrick Hansen on 1/17/18.
//  Copyright © 2018 Patrick Hansen. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        return true
    }

}

