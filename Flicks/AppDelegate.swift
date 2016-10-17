//
//  AppDelegate.swift
//  Flicks
//
//  Created by anegrete on 10/15/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UIApplication.shared.statusBarStyle = .lightContent
        
        window = UIWindow(frame: UIScreen.main.bounds)
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Init NavigationViewController for Now Playing movies
        let nowPlayingNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MoviesViewController
        nowPlayingViewController.endpoint = "now_playing"
        nowPlayingNavigationController.tabBarItem.title = "Now Playing"
        nowPlayingNavigationController.tabBarItem.image = UIImage(named: "now_playing") //25, 50, 75

        // Init NavigationViewController for Top Rated movies
        let topRatedNavigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        let topRatedViewController = topRatedNavigationController.topViewController as! MoviesViewController
        topRatedViewController.endpoint = "top_rated"
        topRatedNavigationController.tabBarItem.title = "Top Rated"
        topRatedNavigationController.tabBarItem.image = UIImage(named: "top_rated")

        // Init TabBarController
        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor.black
        tabBarController.tabBar.tintColor = UIColor.orange
        tabBarController.tabBar.unselectedItemTintColor = UIColor.gray
        tabBarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController]
        tabBarController.delegate = nowPlayingViewController
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        // Init reachability to start monitoring network changes
        self.setupReachability()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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

    // MARK: - Reachability

    func setupReachability() {
        
        // Start monitoring reachability status changes
        let reachabilityManager = AFNetworkReachabilityManager.shared()
        reachabilityManager.startMonitoring()
        reachabilityManager.setReachabilityStatusChange { (AFNetworkReachabilityStatus) in

            switch(AFNetworkReachabilityStatus) {
                
            case .unknown, .notReachable:
                print("Not reachable")
                self.visibleViewController().isOnline(isOnline: false)
                
            case .reachableViaWiFi, .reachableViaWWAN:
                print("Reachable")
                self.visibleViewController().isOnline(isOnline: true)
            }
        }
    }

    // MARK: - View Controllers

    // Get current visible view controller
    func visibleViewController() -> MoviesViewController {
        let tabBarController = self.window?.rootViewController as! UITabBarController
        let navigationViewController = tabBarController.selectedViewController as! UINavigationController
        return navigationViewController.viewControllers[0] as! MoviesViewController
    }
}
