//
//  AppDelegate.swift
//  GiftADeed
//
//  Created by navin on 04/04/18.
//  Copyright © 2018 GiftADeed. All rights reserved.
//SRS : version 31

import UIKit
import Foundation
import UserNotifications
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import SendBirdSDK
import CoreData
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import FBSDKCoreKit
import Google
import GoogleSignIn
import LinkedinSwift
import AVKit
import AVFoundation
import EFInternetIndicator
extension AppDelegate: FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        
        //print("Notification: Firebase FCM delegate remote message.:\(remoteMessage.appData)")
    }
}

// MARK:- UNUserNotificationCenterDelegate
//The delegate methods are used to show notifications to user on all app state.
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       
        completionHandler()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
 
    
    var internetConnectionIndicator: InternetViewIndicator?
    
    
    
    var receivedPushChannelUrl: String?
    
    static let instance: NSCache<AnyObject, AnyObject> = NSCache()
    
    static func imageCache() -> NSCache<AnyObject, AnyObject>! {
        if AppDelegate.instance.totalCostLimit == 104857600 {
            AppDelegate.instance.totalCostLimit = 104857600
        }
        
        return AppDelegate.instance
    }
    var window: UIWindow?
    
    let shareModel: LocationManager = LocationManager.sharedManager() as! LocationManager

    let gcmMessageIDKey = "gcm.message_id"
    var timer: Timer?
    
    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // fetch data from internet now

        completionHandler(.newData);
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // application.statusBarStyle = .lightContent
        application.isStatusBarHidden = true
        //
        self.registerForRemoteNotification()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: Constants.navigationBarTitleFont()]
        UINavigationBar.appearance().tintColor = Constants.navigationBarTitleColor()
        
        application.applicationIconBadgeNumber = 0
        
        SBDMain.setLogLevel(SBDLogLevel.none)
        SBDOptions.setUseMemberAsMessageSender(true)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            
        }

        UINavigationBar.appearance().barTintColor = UIColor(red: 255.0/255.0, green: 102.0/255.0, blue: 0.1/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        //Integrate sendbird key
        SBDMain.initWithApplicationId("SENDBIRD_KEY")
        SBDMain.setLogLevel(SBDLogLevel.none)
        
   //Tabbar
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.darkGray], for: .normal)
         UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.orange], for: .selected)
        //End
        needsUpdate()
       
        
//  LanguageManger.shared.defaultLanguage = .en
        GlobalClass.sharedInstance.setBaseURL();
        
        self.shareModel.afterResume = false
        self.shareModel.addApplicationStatus(toPList: "didFinishLaunchingWithOptions")

        var alert: UIAlertView?
        //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
        if UIApplication.shared.backgroundRefreshStatus == .denied {
            alert = UIAlertView(title: "", message: "The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
            alert?.show()
        } else if UIApplication.shared.backgroundRefreshStatus == .restricted {
            alert = UIAlertView(title: "", message: "The functions of this app are limited because the Background App Refresh is disable.", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "")
            alert?.show()
        }
        else{
            
            if launchOptions?[.location] != nil {
                
                // This "afterResume" flag is just to show that he receiving location updates
                // are actually from the key "UIApplicationLaunchOptionsLocationKey"
                self.shareModel.afterResume = true
                self.shareModel.startMonitoringLocation()
                shareModel.addResumeLocationToPList()
            }
        }
        
        //For background fetch location after every minimun time interval.
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        //Register push notification
        UIApplication.shared.registerForRemoteNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
 
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            // Enable or disable features based on authorization.
            if granted {
                
                //print("Granted")
            }
        }
        
        //TODO: Firebae configuration
        registerForPushNotifications(application: application)
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        
        if FIRInstanceID.instanceID().token() != nil {
            connectToFcm()
        }
        
        let refreshedToken = GlobalClass.sharedInstance.nullToNil(value: FIRInstanceID.instanceID().token() as AnyObject)
        UserDefaults.standard.setValue(refreshedToken, forKey: "FCMTOEKN")
        
        //Default menu index set as Home
        GlobalClass.sharedInstance.menuIndex = "0"
        
        //IQKeyboardManager used to handle keyboard
        IQKeyboardManager.shared.enable = true

        //Set GCM keys
        GMSServices.provideAPIKey(Constant.GooglePlacesApp_ID)
        GMSPlacesClient.provideAPIKey(Constant.GooglePlacesApp_ID)

        //To manage user session
        let defaults = UserDefaults.standard
        let loginFlag = defaults.value(forKey: "loginFlag")
        
        //User seesion handling if flag is TRUE navigate to Home screen otherwise login screen as Root View
        if ((loginFlag as AnyObject).isEqual("TRUE")) {
        
            //API is called for active user count
            self.activeUserCount()

            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let homeViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "home")
            self.window?.rootViewController = homeViewController
            self.window?.makeKeyAndVisible()
//            iRate.sharedInstance().daysUntilPrompt = 5;
//            iRate.sharedInstance().usesUntilPrompt = 20;
//            iRate.sharedInstance().appStoreID = 981778637;
        
        } else {
            
            DispatchQueue.main.async{
                
                self.timer?.invalidate()
                self.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            }
        }
      
        return true
    }
    //Function to check new updates avilable on App store
    func needsUpdate() -> Bool {
        let infoDictionary = Bundle.main.infoDictionary
        let appID = infoDictionary!["CFBundleIdentifier"] as! String
        let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")
        guard let data = try? Data(contentsOf: url!) else {
            //print("There is an error!")
            return false;
        }
        let lookup = (try? JSONSerialization.jsonObject(with: data , options: [])) as? [String: Any]
        if let resultCount = lookup!["resultCount"] as? Int, resultCount == 1 {
            if let results = lookup!["results"] as? [[String:Any]] {
                if let appStoreVersion = results[0]["version"] as? String{
                    let currentVersion = infoDictionary!["CFBundleShortVersionString"] as? String
                    if !(appStoreVersion == currentVersion) {
                        //requesting for authorization
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
                            
                        })
                        let content = UNMutableNotificationContent()
                        
                        //adding title, subtitle, body and badge
                        content.title = "New Version"
                        content.subtitle = "Want to update"
                        content.body = "User Experiance is changed in new version"
                      //  content.badge = 0
                       // content
                        //getting the notification trigger
                        //it will be called after 5 seconds
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                        
                        //getting the notification request
                        let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
                        
                        //adding the notification to notification center
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                        //print("Need to update [\(appStoreVersion) != \(currentVersion)]")
                     //  UIApplication.shared.applicationIconBadgeNumber = 1
                        let alertController = UIAlertController (title: "", message: "Update to new version \(appStoreVersion)", preferredStyle: .alert)
                        
                        let firstAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                            if let url = URL(string: "https://itunes.apple.com/in/app/gift-a-deed/id1391635132?mt=8"),
                                UIApplication.shared.canOpenURL(url){
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                        })
                        alertController.addAction(firstAction)
                        
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        
                        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                        
                        alertWindow.rootViewController = UIViewController()
                        alertWindow.windowLevel = UIWindowLevelAlert + 1;
                        alertWindow.makeKeyAndVisible()
                        //display alert on update version change
                       // alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
                        
//                        UIApplication.shared.openURL(NSURL(string: "https://itunes.apple.com/in/app/gift-a-deed/id1391635132?mt=8")! as URL)
                        return true
                    }
                    else{
                        //requesting for authorization
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
                            
                        })
                        let content = UNMutableNotificationContent()
                        
                        //adding title, subtitle, body and badge
                        content.title = "Hey, version is Up to date."
                        content.subtitle = ""
                        content.body = "`"
                        content.badge = 0
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
                }
            }
        }
        return false
    }

    // MARK: - Push notification configuration
    func registerForPushNotifications(application: UIApplication) {

        //FIRApp.configure()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        FIRApp.configure()
    }
    
    @objc func tokenRefreshNotification(_ notification: Notification) {

        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            //print("FCM: Token does not exist.")
            return
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                //print("FCM: Unable to connect with FCM. \(error.debugDescription)")
            } else {
                //print("Connected to FCM.")
            }
        }
    }
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            #if !(arch(i386) || arch(x86_64))
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings: UNNotificationSettings) -> Void  in
                        guard settings.authorizationStatus == UNAuthorizationStatus.authorized else {
                            return;
                        }
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    })
                }
            }
            #endif
        } else {
            #if !(arch(i386) || arch(x86_64))
            let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
            #endif
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //print("Notification: Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        SBDMain.registerDevicePushToken(deviceToken, unique: true) { (status, error) in
            if error == nil {
                if status == SBDPushTokenRegistrationStatus.pending {
                    
                }
                else {
                    
                }
            }
            else {
                
            }
        }
        #if DEBUG
            FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .sandbox)
        #else
            FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .prod)
        #endif
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if userInfo["sendbird"] != nil {
            let sendBirdPayload = userInfo["sendbird"] as! Dictionary<String, Any>
            let channel = (sendBirdPayload["channel"]  as! Dictionary<String, Any>)["channel_url"] as! String
            let channelType = sendBirdPayload["channel_type"] as! String
            if channelType == "group_messaging" {
                self.receivedPushChannelUrl = channel
            }
        }
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("method for handling events for background url session is waiting to be process. background session id: \(identifier)")
        completionHandler()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    private func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        //print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
          //print(userInfo)
        //print(userInfo)
    }

    //Notification Authorization
    func requestNotificationAuthorization(application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
    }
    
    // MARK: - App delegate methods
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.shareModel.addApplicationStatus(toPList: "applicationDidEnterBackground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
   
        self.connectToFcm()
        
        self.shareModel.addApplicationStatus(toPList: "applicationDidBecomeActive")
        //Remove the "afterResume" Flag after the app is active again.
        self.shareModel.afterResume = false
        self.shareModel.startMonitoringLocation()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
     
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
        
        self.shareModel.addApplicationStatus(toPList: "applicationWillTerminate")
        
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        let loginFlag = UserDefaults.standard.value(forKey: "loginFlag")
        if ((loginFlag as AnyObject).isEqual("TRUE")) {
            
            //To Update user active count
            self.activeUserCount()
        }
    }

    // MARK: - For FaceBook , Linkedin, Google plus URL schema
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if(GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)){
            
            return true
        }
        else if(FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)){
            
            return true
        }
        else if (LinkedinSwiftHelper.application(application, open: url, sourceApplication: nil, annotation: nil)) {
            
            return true
        }
        return false
    }
    
    // MARK: - Active user count
    func activeUserCount (){

        let urlString = Constant.BASE_URL + Constant.active_user
        let url:NSURL = NSURL(string: urlString)!
    
        let request = NSMutableURLRequest(url: url as URL)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpMethod = "POST"

        let userId = UserDefaults.standard.value(forKey: "User_ID") as? String ?? "0"
        let paramString = String(format: "userId=%@", userId)
        request.httpBody = paramString.data(using: String.Encoding.utf8)

                
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request as URLRequest)
        task.resume()
    }
    

    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "GiftADeed")
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

