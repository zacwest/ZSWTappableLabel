//
//  AppDelegate.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        window = {
            let window = UIWindow(frame: UIScreen.mainScreen().bounds)
            window.rootViewController = UINavigationController(rootViewController: RootController())
            window.makeKeyAndVisible()
            return window
        }()
        
        return true
    }
}