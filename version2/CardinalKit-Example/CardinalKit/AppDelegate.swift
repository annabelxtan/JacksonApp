//
//  AppDelegate.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit
import Firebase
import ResearchKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // (1) initialize Firebase SDK
        FirebaseApp.configure()
        configureNotifications()
        
        // (2) check if this is the first time
        // that the app runs!
        cleanIfFirstRun()
        
        // (3) initialize CardinalKit API
        CKAppLaunch()
        
        let config = CKPropertyReader(file: "CKConfiguration")
        UIView.appearance(whenContainedInInstancesOf: [ORKTaskViewController.self]).tintColor = config.readColor(query: "Tint Color")
        
        // Fix transparent navbar in iOS 15
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
}

// Extensions add new functionality to an existing class, structure, enumeration, or protocol type.
// https://docs.swift.org/swift-book/LanguageGuide/Extensions.html
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /**
     The first time that our app runs we have to make sure that :
     (1) no passcode remains stored in the keychain &
     (2) we are fully signed out from Firebase.
     
     This step is required as an edge-case, since
     keychain items persist after uninstallation.
    */
    fileprivate func cleanIfFirstRun() {
        if !UserDefaults.standard.bool(forKey: Constants.prefFirstRunWasMarked) {
            if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
                ORKPasscodeViewController.removePasscodeFromKeychain()
            }
            try? Auth.auth().signOut()
            UserDefaults.standard.set(true, forKey: Constants.prefFirstRunWasMarked)
        }
    }
    
    fileprivate func configureNotifications(){
        if !UserDefaults.standard.bool(forKey: Constants.prefsNotificationsSchedule) {
            let center = UNUserNotificationCenter.current()
                center.delegate = self
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    UserDefaults.standard.set(true, forKey: Constants.prefsNotificationsSchedule)
                    let center = UNUserNotificationCenter.current()
                        center.delegate = self
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Jackson Heart"
                    content.body = "Please Complete Daily Survey"
                    // Configure the recurring date.
                    var dateComponents = DateComponents()
                    dateComponents.calendar = Calendar.current

                    dateComponents.hour = 09  // 19:00 hours
                    dateComponents.minute = 15

                    // Create the trigger as a repeating event.
                    let trigger = UNCalendarNotificationTrigger(
                             dateMatching: dateComponents, repeats: true)
                    // Create the request
                    let uuidString = UUID().uuidString
                    let request = UNNotificationRequest(identifier: uuidString,
                                content: content, trigger: trigger)
                    
                    // Schedule the request with the system.
                    center.add(request) { (error) in }
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        LaunchModel.sharedinstance.showSurveyAfterPasscode = true
        // you must call the completion handler when you're done
        completionHandler()
    }
    
    
}




