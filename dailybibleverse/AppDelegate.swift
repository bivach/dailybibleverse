//
//  AppDelegate.swift
//  dailybibleverse
//
//  Created by Agustin Bivachi on 31/10/17.
//  Copyright © 2017 adepture. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import FBSDKCoreKit
import UserNotifications
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    let sharedLocalStorage = LocalStorage.sharedInstance


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if (sharedLocalStorage.getFirstTimeLaunchingApp()) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { (allawed, error) in
                if(allawed) {
                    //SET DEFAULT TIME IF USER ACCEPT NOTIFICATION 08:00
                    self.sharedLocalStorage.saveHasReminder(true)
                    let content = UNMutableNotificationContent()
                    content.title = "Daily Bible Verse"
                    content.body = "Your Daily Bible Verse is Ready"
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    
                    let userCalendar = Calendar.current
                    var components = userCalendar.dateComponents([.hour, .minute], from: tomorrow!)
                    
                    components.hour = 08
                    components.minute = 00
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                    let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { (error) in
                        if ((error) != nil){
                            print("Error \(String(describing: error))")
                        }
                    }
                } else{
                    self.sharedLocalStorage.saveHasReminder(false)
                }
                
            }
        }
        TWTRTwitter.sharedInstance().start(withConsumerKey:"piJYwNpTii8g3eQcbD745XDfj", consumerSecret:"0rLSM41Q8dBUlF8qUxW4D4pMW82kVxdRXGVs1daHn2IdDgcIzg")
        UNUserNotificationCenter.current().delegate = self
        sharedLocalStorage.saveFirstTimeLaunchingApp(false)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
         GADMobileAds.configure(withApplicationID: "ca-app-pub-0219081932956726/4282096506")
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                         open: url,
                                                         sourceApplication: sourceApplication,
                                                         annotation: annotation)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you will know if this is from closed or background
        print("\(response.notification.request.content.userInfo)")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "dailybibleverse")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

