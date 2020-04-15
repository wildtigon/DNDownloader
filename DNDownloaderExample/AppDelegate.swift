//
//  AppDelegate.swift
//  DNDownloaderExample
//
//  Created by Dat Nguyen Tien on 4/9/20.
//  Copyright © 2020 Dat Nguyen Tien. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DNDownloaderConfig.DOWNLOAD_FOLDER = "TEST"
        
        // Override point for customization after application launch.
        return true
    }
}

